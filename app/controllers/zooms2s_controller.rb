require 'zoom_S2S_oauth'

class Zooms2sController < ApplicationController
  def index
  end
  
  def gettok
    begin 
      zoom_oauth = ZoomS2SOAuth.new
      resp_body = zoom_oauth.get_access_token #calls method to get access token 
      session[:access_token] = resp_body['access_token']
      redirect_to root_path, flash: { success: "Success, Response: #{ resp_body }, \n Access Token: #{ session[:access_token]}" }
  
    rescue StandardError => e 
      puts "Error: #{ e.message }"
      redirect_to root_path, flash: { error: e.message } 
    
    rescue OAuth2::Error 
      puts "Error: #{ e.message }"
      redirect_to root_path, flash: { error: e.message } 
    end
  end

  def new_meeting
    
    meetinginfo = startmeeting(session[:access_token]) #params: (access token, parameters)
  end
end