class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_csrf_meta_tags
  
  include SessionsHelper
  layout 'application'
  
  private
    def set_csrf_meta_tags
      @csrf_meta_tags = helpers.tag('meta', name: 'csrf-token', content: form_authenticity_token)
    end
end

