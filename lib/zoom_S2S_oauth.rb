require 'oauth2'
require 'digest'
require 'base64'
require 'httparty'

CONFIG = YAML.load_file("#{Rails.root}/config/application.yml")[Rails.env] #links to enviromnent YAML file /app/config/application.yaml

class ZoomS2SOAuth

  def initialize #initializer, kept here for ease rather than in /config/initializers, instance variables are not accessible outside this class
    @account_id = CONFIG['ACCOUNT_ID']
    @client_id = CONFIG['CLIENT_ID_S2S']
    @client_secret = CONFIG['CLIENT_SECRET_S2S']
    
    @zoom_base_url = CONFIG['ZOOM_BASE_URL'] 
    @meeting_endpoint = CONFIG['MEETING_ENDPOINT']
    @zoom_token_url = CONFIG['ZOOM_TOKEN_URL']
    
  end
  
  def client
    @client ||= OAuth2::Client.new(
      @client_id, 
      @client_secret, 
      site: 'https://zoom.us'
    )
  end
  
  def get_access_token
    url = @zoom_base_url << @zoom_token_url
    authorisation = "#{@client_id}:#{@client_secret}" 
    encoded_authorisation = Base64.strict_encode64(authorisation)
    puts "Authorization: #{encoded_authorisation}"
    
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => 'zoom.us',
      'Authorization' => "Basic #{encoded_authorisation}"
    }
    payload = {
      grant_type: 'account_credentials',
      account_id: @account_id
    }
    
    puts "Posting request... Size: #{ payload.to_s.length }"
    resp = HTTParty.post(
    url, 
    body: URI.encode_www_form(payload),
    headers: headers,
    #debug_output: $stdout
    )
    
    puts "Posted: \nHeaders: #{headers} \nBody: #{payload} \nAwaiting response..."
    resp_body = JSON.parse(resp.body)
    puts "Response: #{resp_body}"
    return resp_body
  end 
  
  def startmeeting(access_tok, parameters)
    url = @zoom_base_url << @meeting_endpoint
    headers = {
      'Authorization' => "Bearer #(access_tok)",
      'Content-Type' => "application/json"
    }
    payload = parameters.to_json
    
    puts "Posting Request..."
    resp = HTTParty.post(
      url, 
      body: URI.encode_www_form(payload),
      headers: headers
    )
    
    puts "Posted: \nHeaders: #{headers} \nBody: #{payload} \nAwaiting response..."
    resp_body = JSON.parse(resp.body, parameters)
    puts "Response: #{resp_body}"
    return resp_body 
  end
end