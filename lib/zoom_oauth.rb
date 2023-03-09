require 'oauth2'
require 'digest'

CONFIG = YAML.load_file("#{Rails.root}/config/application.yml")[Rails.env] #links to enviromnent YAML file /app/config/application.yaml

class ZoomOAuth

  def initialize #initializer, kept here for ease rather than in /config/initializers, instance variables are not accessible outside this class
    @account_id = CONFIG['ACCOUNT_ID']
    @client_id = CONFIG['CLIENT_ID']
    @client_secret = CONFIG['CLIENT_SECRET']
    @redirect_uri = CONFIG['REDIRECT_URI'] #routes to /zoom/callback
    @zoom_base_url = CONFIG['ZOOM_BASE_URL']  
    @state = 'random' #preset state token
  end
  
  def getstate
    @state 
  end
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
  
  def check_state(recievedstate)
    
    puts "Validating state token..."
    puts "Token: #{recievedstate}"
    
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