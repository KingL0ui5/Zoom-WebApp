class ZoomController < ApplicationController

  def index
    zoom_oauth = ZoomOAuth.new
    redirect_to zoom_oauth.authorise_url
  end

  def callback
    zoom_oauth = ZoomOAuth.new
    token = zoom_oauth.get_token(params[:code])
    # Store the access token for later use
    session[:access_token] = token.token
    
    redirect_to root_path
  end

end