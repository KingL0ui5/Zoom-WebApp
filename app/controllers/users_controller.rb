class UsersController < ApplicationController
    def index
        @users = User.all
    end 

    def show
        begin
            @user = User.find(params[:EmployeeID])
        rescue => e 
            redirect_to users_path, notice: e.message
    end
    
    def new
        @user = User.new
    end 
    
    def create 
        
        department = Department.find(user_parameters[:department].to_i)
        @user = department.users.build(user_parameters.except(:department))
        
        #if @user.save
        #    redirect_to user_path(@user), notice: "User created sucessfully"
        #else 
        #    render :new, status: :unprocessable_entity
        #end
        
        begin 
            @user = User.new(user_parameters)
            
            
            @user.save!
            redirect_to @user
        rescue => e
            Rails.logger.error "Error creating user: #{e.message}"
            render :new
        end
    end
    
    def update
        @user = User.find([params(:EmployeeID)])
        
        begin
            @user.update(user_parameters)
            redirect_to @user
        rescue => e 
            redirect_to user_path, notice: e.message
        end
    end
    
    def destroy 
        @user = User.find(params[:EmployeeID])
        @user.destroy
        
        i = User.last.id
        ActiveRecord::Base.connection.execute("ALTER TABLE users AUTO_INCREMENT = #{(i)} ")
        
        redirect_to users_path, status: :see_other, notice: "User sucessfully destroyed"  
        
    rescue ActiveRecord::UserNotFound
        redirect_to users_path, status: :see_other, notice: "User does not exist"
        
    rescue ActiveRecord::UserNotDestroyed
        redirect_to @user, status: :see_other, notice: "User could not be destroyed, please try again"
        
    end 
    
    private
      def user_parameters
          params.require(:user).permit(:EmployeeID, :Name, :EmailAddress, :EmailAddress_confirmation, :department)
      end
    end
end 
