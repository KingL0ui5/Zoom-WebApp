require 'zoom_S2S_oauth'

class UsersController < ApplicationController
    before_action :check_if_logged_in, only: [:update, :create, :destroy] #ensures that user is logged in first
    
    def index
        @users = User.all
    end
    
    def show
        begin
            @user = User.find(params[:id])
        rescue => e 
            flash[:danger] = e.message
            redirect_to users_path
        end
    end
    
    def new
        @user = User.new
        @departments = Department.all
    end 
    
    def create 
        @zoom_user = Zoom_Users.new
        
        i = user_parameters[:department_id] 
        department = Department.find_by(id: i)
        
        hash = user_parameters.except(:department_id)
        puts hash
        @user = User.new(hash)
        @user.department = department
        @user.save!
        
        zoom_params = hash.except(:EmailAddress, :EmailAddress_confirmation, :password_confirmation, :password)
        
        zoom_params[:email] = hash[:EmailAddress] #foramatting for zoom
        zoom_params[:first_name], zoom_params[:last_name] = hash[:Name].split(" ") 
        formatted_zoom_params = {}
        zoom_params.each do |key, value| 
            formatted_zoom_params[key.downcase] = value
        end
        formatted_zoom_params[:display_name] = hash[:Name]
        puts formatted_zoom_params
        
        begin 
            if !session[:access_token] 
                session[:access_token], session[:access_token_expiry] = @zoom_user.authorise
            end
            resp = @zoom_user.create_user(session[:access_token], formatted_zoom_params)
        
        rescue OAuth2::Error => e #specifically for authentication errors
            flash[:danger] = "OAuth error: #{e.message}"
            render :new
            return
        rescue StandardError => e
            flash[:danger] = e.message
            render :new
            return
        end
        flash[:success] = "User successfully created" 
        redirect_to users_path
        
    rescue 
        render :new 
        #deal with lack of any departments exception
    end
    
    def edit #FIX
        puts "editing"
        @user = User.find(params[:id])
        @department = Department.find_by(params[:department_id])
        session[:user] = @user
    end 
    
    def update
        puts "updating"
        @user = session[:user]
        session[:user] = nil
        
        @user.update(user_parameters)
        @user.valid?
        flash[:success] = "Changes saved"
        redirect_to users_path   
        
    rescue StandardError => e
        flash[:danger] = e.message
        render :edit 
    end
    
    def destroy 
        @user = User.find(params[:id])
        @user.destroy
        
        i = User.last.EmployeeID
        ActiveRecord::Base.connection.execute("ALTER TABLE users AUTO_INCREMENT = #{(i)}")
        
        redirect_to users_path, status: :see_other, flash: { success: "User sucessfully destroyed" } 
        
    rescue ActiveRecord::RecordNotFound
        redirect_to users_path, status: :see_other, flash: { error: "User does not exist" } 
        
    rescue ActiveRecord::RecordNotDestroyed
        redirect_to @user, status: :see_other, flash: { error: "User could not be destroyed, please try again" }
        
    end 
    
    private
      def user_parameters
          params.require(:user).permit(:Name, :EmailAddress, :EmailAddress_confirmation, :password, :password_confirmation, :department_id, :EmployeeID) #params are passed as hashes from the form
      end
end 
