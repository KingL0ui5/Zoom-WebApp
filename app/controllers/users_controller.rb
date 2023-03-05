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
    end
    
    def new
        @user = User.new
        @departments = Department.all
    end 
    
    def create 
        
        i = user_parameters[:department_id] 
        puts i
        additional_parameter = Department.find_by(id: i)
        puts "department: #{additional_parameter}" #for testing
        
        
        #department = Department.find_by(id: i)
        #@user = department.users.build(user_parameters.except(:department_id))
        
        @user = User.new(user_parameters.merge({ department: additional_parameter }))
        if @user.save
            redirect_to user_path(@user), notice: "User created sucessfully"
        else 
            render :new, status: :unprocessable_entity, notice: "Creation of user failed"
        end
        
        @user.save
        redirect_to user_path(@user), notice: "User sucessfully created"
        
    #rescue => e
    #        Rails.logger.error "Error creating user: #{e.message}"
    #        render :new
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
        
    rescue ActiveRecord::RecordNotFound
        redirect_to users_path, status: :see_other, notice: "User does not exist"
        
    rescue ActiveRecord::RecordNotDestroyed
        redirect_to @user, status: :see_other, notice: "User could not be destroyed, please try again"
        
    end 
    
    private
      def user_parameters
          params.require(:user).permit(:Name, :EmailAddress, :EmailAddress_confirmation, :department_id, :department) #params are passed as hashes from the form
      end
end 
