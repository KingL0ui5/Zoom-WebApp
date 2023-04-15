require 'meetingrecord'
require 'zoom_S2S_oauth'

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
    
    def check_timer
      @meetingrecords = Meetingrecord.all
      @meetingrecords.each do |meeting|
        if Time.now - meeting.start_time >= 1.week #deletes records from table after 1 week
          meeting.destroy
          i = Meetingrecord.last.meeting_id
          ActiveRecord::Base.connection.execute("ALTER TABLE meetingrecords AUTO_INCREMENT = #{(i)}") 
        end
        
        if meeting.start_time - Time.now <= 1.hour && !meeting.started && meeting.type != "instant" #sends emails 1 hour before meeting
          puts "sending join link"
          request = Zoom_Meetings.new
          resp = request.get_meeting(session[:access_token], meeting.zoom_meeting_id)
          response_body = JSON.parse(resp.body)
          username = (User.find_by(EmailAddress: response_body['host_email'])).Name
        
          MeetingMailer.meeting_host_email(response_body['host_email'], response_body, username).deliver_now
          meeting.started = True
        end
      end
    
    rescue => e
      if e.message
        if e.message.match(/Status: (124)/)
          zoom = ZoomS2SOAuth.new
          flash[:danger] = "Access token invalid, please try again"
          session[:access_token], session[:access_token_expiry] = zoom.authorise
        end    
      else 
        flash[:danger] = e.message
      end
    end
    
  protected 
    def check_if_logged_in
      unless logged_in?
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end
end