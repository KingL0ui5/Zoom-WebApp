require 'zoom_S2S_oauth'

class Zooms2sController < ApplicationController
  
  def initialize
    @zoom_oauth = ZoomS2SOAuth.new #new instance of zoom s2s functions under base method
  end
  
  def index
  end

  def new_meeting
    render layout: 'application'
    puts "new_meeting"
  end
  
  def create_meeting
    authorise
    puts "Successfully authenticated\nAccess Token: #{session[:access_token]}\nTTL: #{@TTL}"
    
    puts "Creating meeting...."
    zoom_id = session[:EmailAddress]
    parameters = meetingparameters.except(:utf8, :authenticity_token, :commit)
    
    if parameters[:start_time]
      parameters[:start_time] = DateTime.parse(parameters[:start_time]) #parsing from ISO 8601 format to DateTime object
    end 
    
    meetinginfo = @zoom_oauth.startmeeting(session[:access_token], parameters, zoom_id)
    
    host = zoom_id
    topic = meetinginfo['topic']
    join_url = meetinginfo['join_url']
    duration = meetinginfo['duration']
    start_time = meetinginfo['start_time']
    timezone = meetinginfo['timezone']
    start_url = meetinginfo['start_time']
    
    puts "Meeting successfully created!"

  rescue StandardError => e
    render file: "#{Rails.root}/response.html.erb", layout: true, content_type: 'text/html'
    puts "Error: #{ e.message }"
  end
  
  private
    def set_session_expiration
      request.session_options[:expire_after] = @TTL.seconds #sets session timer to TTL of the access token
      puts "Set session expiration time to #{@TTL} seconds"
      #make sure you figure out how to display session expiry error message
    end
    
    def authorise
      puts "Requesting access token"
      session.delete(:access_token)
      resp_body = @zoom_oauth.get_access_token #calls method to get access token 
    
      error = resp_body['reason'] #exception handling for errors on server end
      if error != nil
        puts "Error #{error}"
        redirect_to root_path, flash: { error: "Authorisation failed: #{error}" }
      end 
      
      session[:access_token] = resp_body['access_token'] #use of global variable local to session. Is reset when token expires.
      @token_type = resp_body['token_type']
      @TTL = resp_body['expires_in']
      @scope = resp_body['scope']
      
      set_session_expiration
      #redirect_to root_path, flash: { error: e.message } 
    rescue OAuth2::Error => e
      puts "Error: #{ e.message }"
      redirect_to root_path, flash: { error: e.message }
    end
    
    def meetingparameters
      params.permit(:topic, :duration, :password, :type, :start_time, :timezone, :utf8, :authenticity_token, :commit)
      
      params.require(:duration, :type, :timezone).presence    
    end

end