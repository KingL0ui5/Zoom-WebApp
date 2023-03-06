require 'oauth2'

class ZoomOAuth

  def initialize #get parameters from zoom marketplace
    @client_id = ENV[]
    @client_secret = ENV[]
    @redirect_uri = ENV[]
  end

  def client
    @client ||= OAuth2::Client.new(@client_id, @client_secret, site: 'https://zoom.us')
  end

  def authorise_url
    client.auth_code.authorize_url(redirect_uri: @redirect_uri)
  end

  def get_token(code)
    client.auth_code.get_token(code, redirect_uri: @redirect_uri)
  end

end