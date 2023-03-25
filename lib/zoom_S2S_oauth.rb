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
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => 'zoom.us',
      'Authorization' => "Basic #{encoded_authorisation}"
    }
    payload = {
      grant_type: 'account_credentials',
      account_id: @account_id
    }
    
    puts "Posting request..."
    resp = HTTParty.post(
    url, 
    body: URI.encode_www_form(payload),
    headers: headers,
    debug_output: $stdout
    )
    
    content_type = resp.headers['content-type'] #retrieves content type of response
    
    if content_type != 'application/json;charset=UTF-8'  #if the content type is not JSON, something has happened 
      File.open('response.html.erb', 'w') do |file|
        file.puts(resp.body)
      end
      raise StandardError, '404: Cannot get access token, please try again later'
    end
    
    puts "Response: #{resp}"
    resp_body = JSON.parse(resp.body)
    puts "Response: #{resp_body}"
    return resp_body
  end 
  
  def startmeeting(access_tok, parameters, zoom_user_id)
    url = @zoom_base_url << @meeting_endpoint #in deployment replace with @zoom_base_url << @meeting_endpoint << zoom_user_id << "meetings" assuming that the logged in user has an account with zoom 
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'userId' => "liulouis1@gmail.com",
      'Content-Type' => "application/json"
    }

    puts "Posting Request..."
    puts "Parameters #{parameters}"
    resp = HTTParty.post(
      url, 
      body: URI.encode_www_form(parameters),
      headers: headers,
      debug_output: $stdout
    )
    
    content_type = resp.headers['content-type'] #retrieves content type of response
    
    if content_type != 'application/json;charset=UTF-8'  #if the content type is not JSON, something has happened 
      File.open('response.html.erb', 'w') do |file|
        file.puts(resp.body)
      end
      raise StandardError, '404: Cannot create meeting, please try again later'
    end
    
    puts "Posted: \nHeaders: #{headers} \nBody: #{parameters} \nAwaiting response..."
    resp_body = JSON.parse(resp.body)
    puts "Response: #{resp_body}"
    return resp_body 
  end
end