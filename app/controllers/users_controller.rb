class UsersController < ApplicationController
    def index
        @users = User.all
    end
    
    def show
        begin
            @user = User.find(params[:id])
        rescue => e 
            redirect_to users_path, flash[:danger] = e.message 
        end
    end
    
    def new
        @user = User.new
        @departments = Department.all
    end 
    
    def create 
        i = user_parameters[:department_id] 
        department = Department.find_by(id: i)
        
        hash = user_parameters.except(:department_id)
        @user = User.new(hash)
        @user.department = department
        @user.save!
        redirect_to users_path, flash[:success] = "User successfully created" 
        
    rescue => e
        puts e 
        render :new , flash[:danger] = e.message
        #deal with lack of any departments exception
    end
    
    def edit #FIX
        puts "editing"
        @user = User.find(params[:id])
        @department = Department.find_by(params[:department_id])
    end 
    
    def update
        puts "updating"
        @user = User.find_by(EmployeeID: params[:id]) # this doesn't work - id is not sent in the params
        @user.update(user_parameters)
        @user.valid?
        redirect_to users_path, flash[:success] = "Changes saved"  
        
    rescue => e
        render :edit, flash[:danger] = e.message
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
