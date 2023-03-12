require 'oauth2'
require 'digest'

CONFIG = YAML.load_file("#{Rails.root}/config/application.yml")[Rails.env] #links to enviromnent YAML file /app/config/application.yaml

class ZoomOAuth

  def initialize #initializer, kept here for ease rather than in /config/initializers, instance variables are not accessible outside this class
    @client_id = CONFIG['CLIENT_ID_OAUTH']
    @client_secret = CONFIG['CLIENT_SECRET_OAUTH']
    @redirect_uri = CONFIG['REDIRECT_URI'] #routes to /zoom/callback
    @zoom_base_url = CONFIG['ZOOM_BASE_URL']  
    @state = 'random' #preset state 
  end
  
  def getstate
    @state 
  end
  
  def client
    @client ||= OAuth2::Client.new(
      @client_id, 
      @client_secret, 
      grant_type: 'account_credentials',
      site: 'https://zoom.us', 
      authorize_url: '/oauth/authorize',
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

  def get_access_token(code)  #sends authorisation code and recieves access token
    tok = client.auth_code.get_token(
      code,
      redirect_uri: @redirect_uri
    )
    puts"Access Token (object format): #{tok}" 
    tok 
  end
  
  def check_state(recievedstate)
    
    puts "Validating state token..."
    puts "State Token: #{recievedstate}"
    
    expected_state = hash_state(@state) #checks if the recieved state is the same as the expected state token after hashing it
    unless expected_state == recievedstate
      raise OAuth2::Error.new('OAuth failed: Invalid state token') #raises an Oauth2 error - handled in controllers/zoom_controller.rb
    end 
    puts "Validation successful."
  end

  private 
    def hash_state(state)
      Digest::SHA256.hexdigest("#{state}#{@client_secret}") #hashes the state token with the client secret using SHA256 algorithm
    end
end