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
        @user = User.create(user_parameters)
        if @user.save
            redirect_to user_path(@user), notice: "User created sucessfully"
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
        
        flash[:notice] = 
        redirect_to users_path, status: :see_other, notice: "User destroyed successfully."
    end 
    
    private
      def user_parameters
          params.require(:user).permit(:EmployeeID, :Name, :EmailAddress, :EmailAddress_confirmation, :Department)
      end
end 
