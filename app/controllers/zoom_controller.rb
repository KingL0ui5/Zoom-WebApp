require 'zoom_oauth'

class ZoomController < ApplicationController
  def index
    zoom_oauth = ZoomOAuth.new
    state = zoom_oauth.getstate
    redirect_to zoom_oauth.authorize_url(state)
  end

  def callback
    begin
      zoom_oauth = ZoomOAuth.new
      zoom_oauth.check_state(params[:state])
      code = params[:code] #AUTHORISATION code
      puts "Authorisation code: #{code}" 
      token = zoom_oauth.get_access_token(code) #ACCESS token
      session[:access_token] = token.token
      redirect_to root_path, flash: { success: "Authentication sucessful, Access Token: #{token.token}" }
    
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