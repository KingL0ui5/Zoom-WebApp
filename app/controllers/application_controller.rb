require 'meetingrecord'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_csrf_meta_tags
  before_action :check_access_tok_expiry
  before_action :check_timer
  
  include SessionsHelper
  layout 'application'
  
  private
    def set_csrf_meta_tags
      @csrf_meta_tags = helpers.tag('meta', name: 'csrf-token', content: form_authenticity_token)
    end
    
    def check_access_tok_expiry #removes expired access tokens after TTL see set_session_expiration method 
      if session[:access_token_expiry] && session[:access_token_expiry] < Time.now
        session[:access_token] = nil
        puts "Warning: zoom access token has expired"
      end
    end
    
    def check_if_logged_in
      unless logged_in?
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end
    
    def check_timer
      @meetingrecords = Meetingrecord.all
      @meetingrecords.each do |meeting|
        if meeting.start_time - Time.now <= 1.hour
        
          resp = Zoom_Meetings.get_meeting(session[:access_token], meeting_id)
          response_body = JSON.parse(resp.body)
          username = (User.find_by(EmailAddress: response_body['host_email'])).Name
        
          MeetingMailer.meeting_host_email(response_body['host_email'], response_body, username).deliver_now
        end
      end
    end
end