require 'zoom_oauth'

class ZoomController < ApplicationController
  def index
    zoom_oauth = ZoomOAuth.new
    redirect_to zoom_oauth.authorize_url(zoom_oauth.getstate)
  end

  def callback
    puts "Callback"
    begin
      zoom_oauth = ZoomOAuth.new
      zoom_oauth.check_state(params[:state])
      token = zoom_oauth.get_access_token(params[:code]) # Stores the access token for later use
      session[:access_token] = token.token
      redirect_to root_path, flash: { success: "Authentication sucessful, Access Token: #{session[:access_token]}" }
    
    rescue StandardError => e 
      puts e.message
      redirect_to root_path, flash: { error: e.message }
    rescue OAuth2::Error => e #handles OAuth Errors
      puts e.message 
      redirect_to root_path, flash: { error: e.message } #
      #other exception handling 
    end
  end
end