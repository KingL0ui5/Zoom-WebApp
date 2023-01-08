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
        @department = Department.find(params[:user_id])
        @user = @department.users.create(user_parameters)
        if @user.save
            redirect_to user_path(@user), notice: "User was sucessfully created"
        else 
            render :new, status: :unprocessable_entity
        end
    end
    
    def update
        @user = User.find([params(:id)])
        
        if @user.update(user_parameters)
            redirect_to @user
        else 
            render @edit, status: :unprocessable_entity
        end
    end
    
    def destroy 
        @user = User.find(params[:id])
        @user.destroy
        
        redirect_to root_path, status: :see_other, notice: "User was sucessfully destroyed"
    end 
    
    private
      def user_parameters
          params.require(:user).permit(:EmployeeID, :Name, :EmailAddress, :Department)
      end
end 
