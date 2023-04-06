require 'zoom_S2S_oauth'

class UsersController < ApplicationController
    before_action :check_if_logged_in, only: [:update, :create, :destroy] #ensures that user is logged in first
    before_action :check_access_tok, except: [:initialize]
    
    def initialize
        @zoom_user = Zoom_Users.new
    end
    
    def index
        @users = User.all
    end
    
    def show 
        @user = User.find(params[:id])
        @department = Department.find_by(id: @user.department_id)
        
        begin
            resp = @zoom_user.get_user(session[:access_token], @user.EmailAddress)
            meetings = @zoom_user.list_meetings(session[:access_token], @user.EmailAddress) #calls zoom api
        rescue StandardError => e
            flash[:danger] = e.message
            redirect_to @department, layout: 'application'
            return 
        end
        @resp_body = JSON.parse(resp.body) #response body hash
        meetings_body = JSON.parse(meetings.body)
        @meetings = meetings_body['meetings']
        render layout: 'application'
        
    rescue => e
        flash[:danger] = e.message
        redirect_to @department
    end
    
    def new 
        @user = User.new
        @departments = Department.all
        render layout: 'application'
    end 
    
    def create
        i = user_parameters[:department_id] 
        department = Department.find_by(id: i)
        
        @user = User.new(user_parameters.except(:department_id))
        @user.department = department
        
        details = zoom_formatting(user_parameters)
        puts details 
        
        begin 
            @zoom_user.create_user(session[:access_token], details)
            @user.save
        rescue StandardError => e
            render :new, layout: 'application'
            return
        end
        flash[:success] = "User successfully created" 
        redirect_to @user.department
        
    rescue 
        render :new, layout: 'application'
    end
    
    def edit #FIX authentication code not valid
        @user = User.find(params[:id])
        @department = Department.find_by(params[:department_id])
        session[:user] = @user
    end 
    
    def update
        @user = session[:user]
        session[:user] = nil
        
        @user.update(user_parameters)
        @user.valid?
        
        details = zoom_formatting(user_parameters)
        
        begin 
            @zoom_user.patch_user(session[:access_token], details)
        rescue StandardError => e
            flash[:danger] = e.message
            render :edit, layout: 'application'
            return
        end
        flash[:success] = "Changes saved"
        redirect_to users_path   
        
    rescue => e
        render :edit, layout: 'application' 
    end
    
    def destroy 
        @user = User.find(params[:id])
        
        begin
            @zoom_user.delete_user(session[:access_token], @user.EmailAddress) 
        rescue StandardError => e
            flash[:danger] = e.message
            render :new, layout: 'application'
            return
        end
        
        @user.destroy
        i = User.last.EmployeeID
        ActiveRecord::Base.connection.execute("ALTER TABLE users AUTO_INCREMENT = #{(i)}") #resets auto increment of primary key
        
        flash[:success] = "User successfully destroyed"
        redirect_to department_path, status: :see_other
        
    rescue => e
        flash[:danger] = e.message
        redirect_to users_path, status: :see_other
    end 
    
    private
        def user_parameters
            params.require(:user).permit(:Name, :EmailAddress, :EmailAddress_confirmation, :password, :password_confirmation, :department_id, :EmployeeID) #params are passed as hashes from the form
        end
        
        def zoom_formatting(form_hash)
            zoom_params = form_hash.except(:EmailAddress, :EmailAddress_confirmation, :password_confirmation, :department_id)
            
            zoom_params[:email] = form_hash[:EmailAddress] #foramatting for zoom
            zoom_params[:first_name], zoom_params[:last_name] = form_hash[:Name].split(" ") 
            formatted_zoom_params = {}
            zoom_params.each do |key, value| 
                formatted_zoom_params[key.downcase] = value
            end
            formatted_zoom_params[:display_name] = form_hash[:Name]
            return formatted_zoom_params
        end 
        
        def check_access_tok
            if !session[:access_token] 
                session[:access_token], session[:access_token_expiry] = @zoom_user.authorise
            end
            
        rescue OAuth2::Error => e #specifically for authentication errors
            flash[:danger] = "OAuth error: #{e.message}"
            redirect_to request.referer || root_path
            return
        end 
end 
