require 'oauth2'
require 'digest'
require 'base64'
require 'httparty'
require 'Custom_errors'
require 'json'

CONFIG = YAML.load_file("#{Rails.root}/config/application.yml")[Rails.env] #links to enviromnent YAML file /app/config/application.yaml

class ZoomS2SOAuth
  def initialize #initializer, kept here for ease rather than in /config/initializers, instance variables are not accessible outside this class
    @account_id = CONFIG['ACCOUNT_ID']
    @client_id = CONFIG['CLIENT_ID_S2S']
    @client_secret = CONFIG['CLIENT_SECRET_S2S']
    
    @zoom_base_url = CONFIG['ZOOM_BASE_URL'] 
    @zoom_token_url = CONFIG['ZOOM_TOKEN_URL']
    
    #session[:access_token] = nil
  end  
  
  def client #currently redundant
    @client ||= OAuth2::Client.new(
      @client_id, 
      @client_secret, 
      site: 'https://zoom.us'
    )
  end  
  
  def get_access_token
    puts "Requesting access token"
    url = @zoom_base_url + @zoom_token_url
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
      raise FormatError.new("Authentication Error")
    end
    
    puts "Response: #{resp}"
    resp_body = JSON.parse(resp.body)
    puts "Response: #{resp_body}"
    return resp_body
  end 
end 

class Zoom_Meetings < ZoomS2SOAuth
  def initialize 
    @meeting_endpoint = CONFIG['MEETING_ENDPOINT']
    super 
  end 
  
  def startmeeting(access_tok, parameters, zoom_user_id)
    puts "Creating meeting...."
    url = @zoom_base_url + @meeting_endpoint #in deployment replace with @zoom_base_url + @meeting_endpoint + zoom_user_id + "meetings" assuming that the logged in user has an account with zoom 
    payload = JSON.generate(parameters) #parses form params to JSON
    puts payload
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }

    puts "Posting Request..."
    resp = HTTParty.post(
      url, 
      body: payload,
      headers: headers,
      debug_output: $stdout
    )
    
    content_type = resp.headers['content-type'] #retrieves content type of response
    
    if content_type != 'application/json;charset=UTF-8'  #if the content type is not JSON, something has happened 
      File.open('response.html.erb', 'w') do |file|
        file.puts(resp.body)
      end
      raise FormatError.new("New Meeting POST Error")
    end
    
    puts "Posted: \nHeaders: #{headers} \nBody: #{parameters} \nAwaiting response..."
    resp_body = JSON.parse(resp.body)
    puts "Response: #{resp_body}"
    return resp_body 
  end
  
  def get_meeting
      
  end
end

class Zoom_Users < ZoomS2SOAuth
  def initialize
    @users_url = CONFIG['GETUSERSURL']
    super
  end
  
  def get_user(access_tok, zoom_user_id)
    puts "Requesting user information..."
    url = @zoom_base_url + @users_url + "liulouis1@gmail.com"#zoom_user_id
    
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"     
    }
    
    payload = {
      encrypted_email: false,
      search_by_unique_id: true #can search by unique email adderess to find employee 
    }
    
    puts "Posting request..."
    resp = HTTParty.get(
    url, 
    query: JSON.generate(payload),
    headers: headers,
    debug_output: $stdout
    )
    
    return resp
  end
    
  def create_user(access_tok)
    url = @zoom_base_url + @users_url
    
    resp = HTTParty.post(
      url,
      debug_output: $stdout
      )
  end
  
  def delete_user(access_tok, zoom_user_id)
    url = @zoom_base_url + @users_url + zoom_user_id
    
    resp = HTTParty.delete(
      url,
      debug_output: $stdout
      )
  end
end