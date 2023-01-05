class UsersController < ApplicationController
    def index
        @users = User.all
    end 

    def show
        @user = User.find(params[:id])
    end
    
    def new
        @user = User.new
    end 
    
    def create 
        @user = User.new(user_parameters)
        if @user.save
            redirect_to @user, notice: "User was sucessfully created"
        else 
            render :new, status: :unprocessable_entity
        end
    end
    
    private
      def user_parameters
          params.require(:user).permit(:EmployeeID, :Name, :EmailAddress, :Department)
      end
end 
