require 'zoom_oauth'

class ZoomController < ApplicationController

  def index
    state = 'random'
    zoom_oauth = ZoomOAuth.new
    redirect_to zoom_oauth.authorize_url(state)
  end

  def callback
    puts "Callback"
    begin
      zoom_oauth = ZoomOAuth.new
      zoom_oauth.check_state("abcd")
      token = zoom_oauth.get_access_token(params[:code], params[:state]) # Stores the access token for later use
      session[:access_token] = token.token
      puts "Access_token: #{token}"
      redirect_to root_path
    
    rescue StandardError => e 
      puts e.message
      redirect_to root_path, notice: e.message
    rescue OAuth2::Error => e #handles OAuth Errors
      puts e.message 
      redirect_to root_path, notice: e.message #
      #other exception handling 
    end
  end
end