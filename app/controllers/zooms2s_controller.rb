require 'zoom_S2S_oauth'

class Zooms2sController < ApplicationController
  layout 'application'
  
  def initialize
    @zoom_oauth = ZoomS2SOAuth.new #new instance of zoom s2s functions under base method
    
    puts "Initializing"
    
    @errors = {
      topic: [], 
      type: [], 
      duration: [],
      timezone: []
    }
  end
  
  def index
  end

  def new_meeting
    #using form_tag methods for simplified params hash
    @errors = session.delete(:errors)&.transform_keys(&:to_sym) || { 
      topic: [], 
      type: [], 
      duration: [],
      timezone: []
    } #any errors in the hash will be stored into @errors - otherwise @errors is initialized and session[:errors] is deleted
    render layout: 'application'
  end
  
  def create_meeting
    if check_for_errors
      session[:errors] = @errors #stores hash in session to retain it
      redirect_to '/zooms2s/new_meeting'
      return 
    end 
    
    if !session[:access_token] #only runs if access token is missing
      authorise
    end
    
    flash[:success] = "Successfully authenticated\nAccess Token: #{session[:access_token]}\nTTL: #{@Expires_in}"
    
    zoom_id = session[:EmailAddress]
    i = meetingparameters[:department_id] 
    department = Department.find_by(id: i)
    
    parameters = meetingparameters.except(:message, :department_id, :utf8, :authenticity_token, :commit) #removing clutter and fields that are not submitted to the zoom api
    
    meetinginfo = meeting(parameters)
    
    details = {
      message: meetingparameters[:message],
      host: zoom_id,
      topic: meetinginfo['topic'],
      join_url: meetinginfo['join_url'],
      duration: meetinginfo['duration'],
      start_time: meetinginfo['start_time'],
      timezone: meetinginfo['timezone'],
      start_url: meetinginfo['start_url']
    }
    
    send_emails(department, details, parameters[:type])
    
    flash[:success] = "Meeting successfully created!"

  rescue StandardError => e 
    puts e.message
  
  rescue FormatError 
    render file: "#{Rails.root}/response.html.erb", layout: true, content_type: 'text/html'
  end
  
  private
    def set_session_expiration
      session[:access_token_expiry] = @Expires_in.seconds.from_now
      #make sure you figure out how to display session expiry error message
    end
    
    def authorise
      session.delete(:access_token)
      resp_body = @zoom_oauth.get_access_token #calls method to get access token 
    
      error = resp_body['reason'] #exception handling for errors on server end
      if error != nil
        puts "Error #{error}"
        redirect_to root_path, flash: { error: "Authorisation failed: #{error}" }
      end 
      
      session[:access_token] = resp_body['Access_token'] #use of global variable local to session. Is reset when token expires.
      @token_type = resp_body['Token_type']
      @Expires_in = resp_body['Expires_in']
      @scope = resp_body['scope']
      
      set_session_expiration
    rescue OAuth2::Error => e #specifically for authentication errors
      puts "Error: #{ e.message }"
      redirect_to root_path, flash: { error: e.message }
    end
    
    def meetingparameters
      params.permit(:message, :topic, :duration, :password, :type, :start_time, :timezone, :department_id, :utf8, :authenticity_token, :commit)
    end
    
    def check_for_errors
      puts "Checking for errors"
      
      [:duration, :type].each do |field|
        if params[field].blank?
          @errors[field] = "This field must not be blank"
        end
      end
      
      if params[:topic].length > 200 
        @errors[:topic] = "Length cannot be greater than 200 characters"
      end
      
      if params[:type] == 2 && params[:start_time] == nil
        @errors[:start_time] = "Cannot be blank if meeting type is scheduled "
      end 
      
      if params[:type] == 2 && params[:timezome] == nil
        @errors[:timezone] = "Cannot be blank if meeting type is scheduled "
      end 
      
      if !@errors.empty?
        true
      end
    end  
    
    def send_emails(department, details, type)
      users = department.users 
      username = (User.find_by(id: session[:user_EmployeeID])).Name
      users.each do |user| #iterates through all users in department 
        if user.EmailAddress == session[:user_EmailAddress]
        else
          MeetingMailer.meeting_email(user.Name, user.EmailAddress, details, username).deliver_now
        end
      end
      
      if type == 1
        MeetingMailer.meeting_host_email(session[:user_EmailAddress], details, username)
      else 
        #get meeting request
        MeetingMailer.meeting_confirmation_email(session[:user_EmailAddress], details, username).deliver_now
      end
    end 
    
    def meeting(parameters)
      if parameters[:start_time]
        parameters[:start_time] = DateTime.parse(parameters[:start_time]).strftime('%Y-%m-%dT%H:%M:%S') #parsing from ISO 8601 format to yyyy-MM-ddTHH:mm:ss format as required by zoom
        if parameters[:timezone] == "GMT"
          parameters[:timezone] = nil
          parameters[:start_time] << "Z" #adding "Z" to the end for GMT timezone as required by zoom 
        end
      end
      
      parameters.to_json #parses form params to JSON
      return @zoom_oauth.startmeeting(session[:access_token], parameters, zoom_id) #returns details of new meeting
    end 
end