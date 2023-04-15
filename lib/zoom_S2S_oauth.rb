require 'base64'
require 'httparty'
require 'json'

CONFIG = YAML.load_file("#{Rails.root}/config/application.yml")[Rails.env] #links to enviromnent YAML file /app/config/application.yaml

class ZoomS2SOAuth
  def initialize #initializer, kept here for ease rather than in /config/initializers, instance variables are not accessible outside this class
    @account_id = CONFIG['ACCOUNT_ID']
    @client_id = CONFIG['CLIENT_ID_S2S']
    @client_secret = CONFIG['CLIENT_SECRET_S2S']
    
    @zoom_base_url = CONFIG['ZOOM_BASE_URL'] 
  end
  
  def authorise
    url = CONFIG['ZOOM_TOKEN_URL']
    authorisation = "#{@client_id}:#{@client_secret}" 
    encoded_authorisation = Base64.strict_encode64(authorisation) #encoding authorisation code 
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => 'zoom.us',
      'Authorization' => "Basic #{encoded_authorisation}"
    }
    payload = {
      grant_type: 'account_credentials',
      account_id: @account_id
    }
      
    resp = HTTParty.post(
    url, 
    body: URI.encode_www_form(payload),
    headers: headers,
    debug_output: $stdout
    )
    status = resp.code
    if status == 400
      raise OAuth2::Error, "Error: #{resp['error']}"
    end
      
    puts "Response: #{resp}"
    resp_body = JSON.parse(resp.body)
  
    error = resp_body['reason'] #exception handling for errors on server end
    if error != nil
      flash[:danger] = "Authorisation failed: #{error}" 
      redirect_to root_path
    end 
      
    access_token = resp_body['access_token']
    expires_in = resp_body['expires_in']
    
    return access_token, set_session_expiration(expires_in)
    
  rescue StandardError => e #for handling rate limit
    if e.message.include?("429")
      flash[:danger] = "Warning: Zoom API rate limit exceeded. You cannot make any more requests for 24 hours on this account.\nYou are about to be signed out"
      redirect_to root_path
      sleep 30.seconds #waits for 30 seconds then signs out user, and resets access token.
      reset_session
    else 
      raise e 
    end
  end 
  
  
  private
    def set_session_expiration(expires_in)
      expires_in.seconds.from_now
    end

  protected 
    @account_id 
    @client_id
    @client_secret
  
end 

class Zoom_Meetings < ZoomS2SOAuth
  def initialize 
    super
    @meeting_url = @zoom_base_url + 'meetings/' 
  end 
  
  def startmeeting(access_tok, parameters, host_id)
    url = @zoom_base_url + "users/#{host_id}/meetings"
    payload = JSON.generate(parameters) #parses form params to JSON
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }

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
    
    resp_body = JSON.parse(resp.body)
    puts "Response: #{resp_body}"
    return resp_body 
    
  rescue StandardError => e
    if e.message.include?("429")
      flash[:danger] = "Warning: Zoom API rate limit exceeded. You cannot make any more requests for 24 hours on this account.\nYou are about to be signed out"
      redirect_to root_path
      sleep 30.seconds #waits for 30 seconds then signs out user, and resets access token.
      reset_session
    else 
      raise e
    end
  end
  
  def get_meeting(access_tok, meeting_id)
    url = @meeting_url + meeting_id
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    
    resp = HTTParty.get(
      url,
      headers: headers,
      debug_output: $stdout
      )
    if resp.code != 200
      raise StandardError, "Status: #{resp['code']},\nError: #{resp['message']}"
    end
    
    return resp 
  rescue StandardError => e
    if e.message.include?("429")
      flash[:danger] = "Warning: Zoom API rate limit exceeded. You cannot make any more requests for 24 hours on this account.\nYou are about to be signed out"
      redirect_to root_path
      sleep 30.seconds #waits for 30 seconds then signs out user, and resets access token.
      reset_session
    else 
      raise e
    end
  end
  
  private
    @meeting_url
end

class Zoom_Users < ZoomS2SOAuth
  def initialize
    super #runs initializer of ZoomS2SOAuth 
    @users_url = @zoom_base_url + 'users/'
  end
  
  def get_user(access_tok, zoom_user_id)
    url = @users_url + zoom_user_id
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
    query: payload,
    headers: headers,
    debug_output: $stdout
    )
    puts resp
    if resp.code != 200 
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    elsif resp.code == 1001 
      raise StandardError, "Error: #{resp['message']} Ensure that user has activated their account"
    end 
    return resp
    
  rescue StandardError => e
    if e.message.include?("429")
      flash[:danger] = "Warning: Zoom API rate limit exceeded. You cannot make any more requests for 24 hours on this account.\nYou are about to be signed out"
      redirect_to root_path
      sleep 30.seconds #waits for 30 seconds then signs out user, and resets access token.
      reset_session
    else 
      raise e
    end    
  end
    
  def create_user(access_tok, details)
    url = @users_url
    details[:type] = 2
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    
    payload = {
      action: "create", 
      user_info: details #nest user_info for zoom api
    }
    
    resp = HTTParty.post(
      url,
      headers: headers,
      body: JSON.generate(payload),
      debug_output: $stdout
      )
      
    puts resp 
    if resp.code != 201 
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    end 
    
  rescue StandardError => e
    if e.message.include?("429")
      flash[:danger] = "Warning: Zoom API rate limit exceeded. You cannot make any more requests for 24 hours on this account.\nYou are about to be signed out"
      redirect_to root_path
      sleep 30.seconds #waits for 30 seconds then signs out user, and resets access token.
      reset_session
    else 
      raise e
    end    
  end
  
  def patch_user(access_tok, details) #test
    url = @users_url + details['email']
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    
    resp = HTTParty.patch(
      url,
      headers: headers,
      body: JSON.generate(details),
      debug_output: $stdout
      )
      
    puts resp   
    if resp.code != 204
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    end
    
  rescue StandardError => e
    if e.message.include?("429")
      flash[:danger] = "Warning: Zoom API rate limit exceeded. You cannot make any more requests for 24 hours on this account.\nYou are about to be signed out"
      redirect_to root_path
      sleep 30.seconds #waits for 30 seconds then signs out user, and resets access token.
      reset_session
    else 
      raise e
    end
  end 
  
  def delete_user(access_tok, zoom_user_id) #CHECK, test
    url = @users_url + zoom_user_id + "?action=delete"
    
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    
    resp = HTTParty.delete(
      url,
      headers: headers, 
      debug_output: $stdout
      )
      
    puts resp 
    if resp.code != 204
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    end 
  rescue StandardError => e
    if e.message.include?("429")
      flash[:danger] = "Warning: Zoom API rate limit exceeded. You cannot make any more requests for 24 hours on this account.\nYou are about to be signed out"
      redirect_to root_path
      sleep 30.seconds #waits for 30 seconds then signs out user, and resets access token.
      reset_session
    else 
      raise e
    end
  end
  
  def list_meetings(access_tok, zoom_user_id) #test
    url = @users_url + zoom_user_id + "/meetings"
    
    headers = {
      'Authorization' => "Bearer #{access_tok}",
      'Content-Type' => "application/json"
    }
    
    payload = {
      page_size: 300
    }
    
    resp = HTTParty.get(
      url,
      headers: headers,
      query: JSON.generate(payload),
      debug_output: $stdout
      )
      
    puts resp 
    
    if resp.code == 1001 
      raise StandardError, "Error: #{resp['message']} Ensure that user has activated their account"
    elsif resp.code != 200
      raise StandardError, "Code: #{resp['code']}\nError: #{resp['message']}" 
    end 
    return resp
    
  rescue StandardError => e
    if e.message.include?("429")
      flash[:danger] = "Warning: Zoom API rate limit exceeded. You cannot make any more requests for 24 hours on this account.\nYou are about to be signed out"
      redirect_to root_path
      sleep 30.seconds #waits for 30 seconds then signs out user, and resets access token.
      reset_session
    else 
      raise e
    end
  end
  
  private 
    @users_url
  
end