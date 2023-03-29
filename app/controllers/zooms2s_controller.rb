require 'zoom_S2S_oauth'

class Zooms2sController < ApplicationController
  layout 'application'
  before_action :check_access_tok, except: [:initialize]
  
  def initialize
    @meeting = Zoom_Meetings.new #new instance of zoom s2s functions under base method
    @zoom_user = Zoom_Users.new
    @errors = { }
  end
  
  def testing
    check_if_user_exists(session[:access_token], "test")
    session[:access_token] = nil
  end

  def new_meeting
    @errors = session.delete(:errors)&.transform_keys(&:to_sym) || { } #any errors in the hash will be stored into @errors - otherwise @errors is initialized and session[:errors] is deleted
    render layout: 'application'
  end
  
  def create_meeting
    puts meetingparameters #for debugging
    if check_for_errors
      session[:errors] = @errors #stores hash in session to retain it
      redirect_to '/zooms2s/new_meeting'
      return 
    end 
    
    flash[:success] = "Successfully authenticated\nAccess Token: #{session[:access_token]}\nTTL: #{@Expires_in}"
    
    if !check_if_user_exists(session[:access_token], session[:user_EmailAddress]) #check that user exists before attempting to create meeting
      flash[:danger] = "Host user does not have an account with zoom. Ensure that host has an account before creating a new meeting"
      redirect_to '/zooms2s/new_meeting'
      return
    end
    
    i = meetingparameters[:department_id] 
    department = Department.find_by(id: i)
    zoom_id = session[:user_EmailAddress]
    
    parameters = meetingparameters.except(:message, :department_id, :utf8, :authenticity_token, :commit).symbolize_keys #removing clutter and fields that are not submitted to the zoom api & symbolizes keys
    
    meetinginfo = meeting(parameters, zoom_id)
    
    details = { #hash to be passed to subroutines
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
    flash[:danger] = e.message
    redirect_to '/zooms2s/new_meeting'
  rescue OAuth2::Error => e #specifically for authentication errors
    flash[:danger] = "OAuth error: #{e.message}"
    redirect_to 'zooms2s/new_meeting'
  end 
  private 
    def check_access_tok
      if !session[:access_token] 
        session[:access_token], session[:access_token_expiry] = @zoom_user.authorise
      end
    end 
  
    def meetingparameters
      params.permit(:message, :topic, :duration, :password, :type, :start_time, :timezone, :department_id, :utf8, :authenticity_token, :commit)
    end
    
    def check_for_errors
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
        puts "errors found #{@errors}"
        true
      end
    end  
    
    def send_emails(department, details, type)
      users = department.users 
      username = (User.find_by(id: session[:user_EmployeeID])).Name
      users.each do |user| #iterates through all users in department 
        if user.EmailAddress == session[:user_EmailAddress]
          MeetingMailer.meeting_host_email(session[:user_EmailAddress], details, username).deliver_now #delivers seperate email to meetinghost
          hold_email(details[:start_time])
        else
          MeetingMailer.meeting_email(user.Name, user.EmailAddress, details, username).deliver_now
        end
      end
      
      if type == 1
        MeetingMailer.meeting_host_email(session[:user_EmailAddress], details, username).deliver_now
      else 
        #get meeting request
        MeetingMailer.meeting_confirmation_email(session[:user_EmailAddress], details, username).deliver_now
      end
    end 
    
    def meeting(parameters, zoom_id)
      if parameters[:start_time]
        parameters[:start_time] = DateTime.parse(parameters[:start_time]).strftime('%Y-%m-%dT%H:%M:%S') #parsing from ISO 8601 format to yyyy-MM-ddTHH:mm:ss format as required by zoom
        if parameters[:timezone] == "GMT"
          parameters[:timezone] = nil
          parameters[:start_time] << "Z" #adding "Z" to the end for GMT timezone as required by zoom 
        end
      end
  
      return @meeting.startmeeting(session[:access_token], parameters, zoom_id) #returns details of new meeting
    end
    
    def check_if_user_exists(access_token, zoom_user_id)
      begin resp = @zoom_user.get_user(access_token, zoom_user_id)
        code = resp.code
        body = JSON.parse(resp.body)
        
      rescue StandardError => e 
        puts e.message
        flash[:danger] = e.message
      
      ensure 
        if code == 1001
          return false
        end
        return true 
      end
    end
    
    def hold_email(start_time)
      session[:email_timer] = DateTime.parse(start_time)
    end 
end