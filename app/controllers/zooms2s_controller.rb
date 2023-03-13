require 'zoom_S2S_oauth'

class Zooms2sController < ApplicationController
  def index
  end
  
  def gettok
    Session.destroy_all #destroys all session entries to avoid overflow errors
    puts "Sessions destroyed..."
    begin 
      zoom_oauth = ZoomS2SOAuth.new
      resp_body = zoom_oauth.get_access_token #calls method to get access token 
      
      e = resp_body['reason']
      if e != nil
        redirect_to root_path, flash: { error: "Authorisation failed: #{ e }" }
      end 
      
      session[:access_token] = resp_body['access_token']
      session[:token_type] = resp_body['token_type']
      session[:TTL] = resp_body['expires_in']
      session[:scope] = resp_body['scope']
      
      redirect_to root_path, flash: { success: "Successfully authenticated\nAccess Token: #{session[:access_token]}\nTTL: #{session[:TTL]}" }
  
    rescue StandardError => e 
      puts "Error: #{ e.message }"
      redirect_to root_path, flash: { error: e.message } 
    
    rescue OAuth2::Error => e
      puts "Error: #{ e.message }"
      redirect_to root_path, flash: { error: e.message } 
      
    rescue ActionController::SessionOverflowError => e
      puts "Error: #{e.message}"
      redirect_to root_path, flash: { error: "Session overflow error: #{e.message}\nPlease restart application and try again" }
    end
  end

  def new_meeting
    meetinginfo = startmeeting(session[:access_token], ) #([access token], [parameters for new meeting request])
  end
end