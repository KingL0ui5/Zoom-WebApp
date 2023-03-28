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
  end
  
  def get_access_token
    puts "Requesting access token"
    url = 'https://api.zoom.us' + '/oauth/token'
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
    status = resp.code
    if status == 400
      raise OAuth2::Error, "Error: #{resp['error']}, please check parameters"
    end
    
    puts "Response: #{resp}"
    resp_body = JSON.parse(resp.body)
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
    url = 'https://api.zoom.us' + '/v2/users/liulouis1@gmail.com/meetings' #in deployment replace with @zoom_base_url + @meeting_endpoint + zoom_user_id + "meetings" assuming that the logged in user has an account with zoom 
    payload = JSON.generate(parameters) #parses form params to JSON
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
    
    status = resp.code 
    if status != 201
      raise StandardError, "Status: #{resp['code']},\nError: #{resp['message']}"
    end 
    
    puts "Posted: \nHeaders: #{headers} \nBody: #{parameters} \nAwaiting response..."
    resp_body = JSON.parse(resp.body)
    puts "Response: #{resp_body}"
    return resp_body 
  end
  
  def get_meeting(access_tok, meeting_id)
    url = 'https://api.zoom.us' + "/v2/meetings/" + meeting_id
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    
    resp = HTTParty.get(
      url,
      headers: headers,
      debut_output: $stdout
      )
    if resp.code != 200
      raise StandardError, "Status: #{resp['code']},\nError: #{resp['message']}"
    end
  end
end

class Zoom_Users < ZoomS2SOAuth
  def initialize
    @users_url = CONFIG['USERSURL']
    super
  end
  
  def get_user(access_tok, zoom_user_id)
    puts "Requesting user information..."
    url = 'https://api.zoom.us' + '/v2/users/' + "liulouis1@gmail.com"#zoom_user_id
    puts "get user url: #{url}"
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"     
    }
    
    payload = {
      encrypted_email: false,
      search_by_unique_id: false #can search by unique email adderess to find employee 
    }
    
    resp = HTTParty.get(
    url,
    query: JSON.generate(payload),
    headers: headers,
    debug_output: $stdout
    )
    if resp.code != 200 
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    end 
    return resp
  end
    
  def create_user(access_tok, details) #test
    url = 'https://api.zoom.us' + '/v2/users/'
    details[:type] = 2
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    
    payload = {
      action: "create", 
      user_info: details #nested hash for zoom api
    }
      
    resp = HTTParty.post(
      url,
      headers: headers,
      body: JSON.generate(payload),
      debug_output: $stdout
      )
      if resp.code != 201 
        raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
      end 
    return resp
  end
  
  def patch_user(access_tok, zoom_user_id, details) #test
    url = 'https://api.zoom.us' + '/v2/users/' + zoom_user_id
    
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    
    resp = HTTParty.patch(
      url,
      headers: headers,
      body: JSON.generate(details)
      debug_output
      )
    if resp.code != 204
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    end       
    return resp 
  end 
  
  def delete_user(access_tok, zoom_user_id, transfer_to) #CHECK, test
    url = 'https://api.zoom.us' + '/v2/users/' + zoom_user_id
    
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    payload = {
      action: "delete",
      encrypted_email: "false",
      transfer_email: "#{transfer_to}" #not sure whether to include or not
    }
    
    resp = HTTParty.delete(
      url,
      headers: headers, 
      query: JSON.generate(payload),
      debug_output: $stdout
      )
    if resp.code != 204
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    end 
    return resp 
  end
  
  def list_meetings(access_tok, zoom_user_id) #test
    url = 'https://api.zoom.us' + '/v2/users/' + zoom_user_id
    
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    payload = {
      page_size: 300
    }
    
    resp = HTTParty.get(
      url,
      headers: headers 
      query: JSON.generate(payload),
      debug_output: $stdout
      )
    
    if resp.code != 200
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    end 
    return resp 
  end
end