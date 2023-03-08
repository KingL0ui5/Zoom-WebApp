require 'oauth2'
require 'digest'

CONFIG = YAML.load_file("#{Rails.root}/config/application.yml")[Rails.env]

class ZoomOAuth

  def initialize #initializer, kept here for ease rather than in /config/initializers, instance variables are not accessible outside this class
    @client_id = CONFIG['CLIENT_ID']
    @client_secret = CONFIG['CLIENT_SECRET']
    @redirect_uri = CONFIG['REDIRECT_URI'] #/zoom/callback
    @zoom_base_url = CONFIG['ZOOM_BASE_URL']  
  end

  #ZOOM_ADD_OAUTH = 'https://zoom.us/oauth/authorize?response_type=code&client_id=QlCPXZkQQoSJdwYjILLAiA&redirect_uri=https%3A%2F%2Fc68dc96b16ad48c6ba78dbbb297e85d4.vfs.cloud9.us-east-1.amazonaws.com%2Fzoom%2Fcallback'
  #ZOOM_GET_AUTHCODE = 'https://zoom.us/oauth/token?grant_type=authorization_code&code='
  #ZOOM_AUTH = 'https://zoom.us/oauth/authorize?response_type=code&client_id='
  #Make it possible to change this 
  
  def client
    @client ||= OAuth2::Client.new(
      @client_id, 
      @client_secret, 
      site: 'https://zoom.us', 
      authorize_url: '/oauth/authorize',
      token_url: '/oauth/token'
    )
  end
  
  def authorize_url(state)
    url = client.auth_code.authorize_url(
      redirect_uri: @redirect_uri,
      state: hash_state(state) #state token - prevents CSRF attacks
    )
    puts "variables: \nClientID #{@client_id}\nClientSecret #{@client_secret}"
    url
  end

  def get_access_token(code)
    client.auth_code.get_token(
      code, 
      redirect_uri: @redirect_uri
    )
  end
  
  def check_state(state)
    puts "checking"
    expected_state = hash_state(params[state]) #checks if the recieved state is the same as the expected state token
    unless expected_state == state
      raise OAuth2::Error.new('Invalid state token') #raises an Oauth2 error - handled in controllers/zoom_controller.rb
    end 
  end

  private 
    def hash_state(state)
      Digest::SHA256.hexdigest("#{state}#{@client_secret}") #hashes the state token with the client secret
    end
    
end