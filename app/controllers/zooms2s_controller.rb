require 'zoom_S2S_oauth'

class Zooms2sController < ApplicationController
  def index
  end
  
  def authorise
    puts "Resetting Session..."
    reset_session
    zoom_oauth = ZoomS2SOAuth.new
    resp_body = zoom_oauth.get_access_token #calls method to get access token 
    
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
      
    redirect_to root_path, flash: { success: "Successfully authenticated\nAccess Token: #{resp_body['access_token']}\nTTL: #{@TTL}" }
  
  rescue StandardError => e
    reset_session
    render file: "#{Rails.root}/response.html.erb", layout: true, content_type: 'text/html'
    puts "Error: #{ e.message }"
    #redirect_to root_path, flash: { error: e.message } 
  
  rescue OAuth2::Error => e
    reset_session
    puts "Error: #{ e.message }"
    redirect_to root_path, flash: { error: e.message }
  end
  
  def new_meeting
    zoom_id = params[:session][:EmailAddress]
    parameters = params.except(:auth_token, :password, :secret_field, :userId) #gets required params from form 
    
    meetinginfo = startmeeting(session[:access_token], parameters, zoom_id)
    
    host = zoom_id
    topic = meetinginfo['topic']
    join_url = meetinginfo['join_url']
    duration = meetinginfo['duration']
    start_time = meetinginfo['start_time']
    timezone = meetinginfo['timezone']
    start_url = meetinginfo['start_time']
    
    puts "Meeting successfully created!"
    
  end
  
  private
    def set_session_expiration
      request.session_options[:expire_after] = @TTL.seconds #sets session timer to TTL of the access token
      puts "Set session expiration time to #{@TTL} seconds"
      #make sure you figure out how to display session expiry error message
    end
end