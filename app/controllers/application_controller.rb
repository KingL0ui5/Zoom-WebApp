class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_csrf_meta_tags
  
  include SessionsHelper
  layout 'application'
  
  private
    def set_csrf_meta_tags
      @csrf_meta_tags = helpers.tag('meta', name: 'csrf-token', content: form_authenticity_token)
    end
    
    def check_access_tok_expiry #removes expired access tokens after TTL see set_session_expiration method 
      if session[:access_token_expiry] && session[:access_token_expiry] < Time.now
        session[:access_token] = nil
        flash[:danger] = "Warning Session Timeout: access token expired."
      end
    end
end

