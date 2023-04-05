require 'zoom_S2S_oauth'

class Zooms2sController < ApplicationController
  before_action :check_access_tok, except: [:initialize]
  
  def initialize
    @meeting = Zoom_Meetings.new #new instance of zoom s2s functions under base method
    @zoom_user = Zoom_Users.new
    @errors = { }
  end
  
  def testing #for testing
    check_if_user_exists(session[:access_token], "test")
    session[:access_token] = nil
  end

  def new_meeting
    @errors = session.delete(:errors)&.transform_keys(&:to_sym) || { } #keys are transformed into strings when stored in session 
    render layout: 'application'
  end
  
  def create_meeting
    if check_for_errors
      session[:errors] = @errors #stores hash in session to retain it across subroutines
      redirect_to '/zooms2s/new_meeting'
      return
    end 
  
    if !check_if_user_exists(session[:access_token], session[:user_EmailAddress]) #check that user exists before attempting to create meeting
      flash[:danger] = "Host user is not registered under zoom"
      redirect_to '/zooms2s/new_meeting'
      return
    end
    
    i = meetingparameters[:department_id] 
    department = Department.find_by(id: i) #no need for exceptions - form only allows existing departments
    zoom_user_id = session[:user_EmailAddress]

    meetingparameters[:start_time], meetingparameters[:timezone] = format_date(meetingparameters[:start_time], meetingparameters[:timezone])
    parameters = meetingparameters.except(:message, :department_id, :utf8, :authenticity_token, :commit).symbolize_keys #removing clutter and fields that are not submitted to the zoom api & symbolizes keys
    
    begin
      
      meetinginfo = @meeting.startmeeting(session[:access_token], parameters, zoom_user_id)
      
      details = { 
        meeting_id: meetinginfo['id'],
        message: meetingparameters[:message],
        host: zoom_user_id,
        topic: meetinginfo['topic'],
        join_url: meetinginfo['join_url'],
        duration: meetinginfo['duration'],
        start_time: meetinginfo['start_time'],
        timezone: meetinginfo['timezone'],
        start_url: meetinginfo['start_url']
      }
      
      send_emails(department, details, parameters[:type])
      
      recordparams = meetingparameters.store(:EmployeeID, session[:user_EmployeeID])
      recordparams.store(:zoom_meeting_id, meetinginfo['id'])
      Meetingrecord.new(recordparams)
      
      flash[:success] = "Meeting successfully created!"
      redirect_to root_path
  
    rescue StandardError => e #any errors from zoom
      flash[:danger] = e.message
      redirect_to '/zooms2s/new_meeting'
    end
  end 

  private 
    def check_access_tok
      if !session[:access_token] 
        session[:access_token], session[:access_token_expiry] = @zoom_user.authorise
      end
      
    rescue OAuth2::Error => e #specifically for authentication errors
      flash[:danger] = "OAuth error: #{e.message}"
      redirect_to 'zooms2s/new_meeting'  
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
        @errors[:start_time] = "Cannot be blank if meeting type is scheduled"
      end 
      
      if params[:type] == 2 && params[:timezone] == nil
        @errors[:timezone] = "Cannot be blank if meeting type is scheduled"
      end 
      
      if !@errors.empty?
        return true
      end
    end  
    
    def send_emails(department, details, type)
      users = department.users 
      username = (User.find_by(EmailAddress: details['host'])).Name
      host_email = details['host']
      users.each do |user| #iterates through all users in department 
        if user.EmailAddress == host_email
          if type == 1 #instant meeting so join link needed now
            MeetingMailer.meeting_host_email(host_email, details, username).deliver_now
          else #join link not needed
            MeetingMailer.meeting_confirmation_email(host_email, details, username).deliver_now #delivers seperate email to meetinghost
          end
        else
          MeetingMailer.meeting_email(user.Name, user.EmailAddress, details, username).deliver_now
        end
      end
    end 
    
    def format_date(start_time, timezone)
      if start_time
        start_time = DateTime.parse(start_time).strftime('%Y-%m-%dT%H:%M:%S') #parsing from ISO 8601 format to yyyy-MM-ddTHH:mm:ss format as required by zoom
        if timezone == "GMT"
          timezone = nil
          start_time << "Z" #adding "Z" to the end for GMT timezone as required by zoom 
        end
      end
  
      return start_time, timezone
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
end