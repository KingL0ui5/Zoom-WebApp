class DepartmentsController < ApplicationController
    before_action :check_if_logged_in, only: [:update, :create, :destroy] #ensures that user is logged in first
    
    def index
        @departments = Department.all
    end 
    
    def show
        @department = Department.find(params[:id])
        @users = @department.users 
        
    rescue => e 
        flash[:danger] = e.message
        redirect_to department_path
    end
    
    def new
        @department = Department.new
        session[:department] = @department
    end 
    
    def create 
        @department = Department.new(params.require(:department).permit(:name))
        @department.save!
        flash[:success] = "Department created successfully"
        redirect_to @department
        
    rescue => e
        flash[:danger] = e.message
        render :new
    end
    
    def edit #FIX
        @department = Department.find(params[:id])
        session[:department] = @department
    end 
    
    def update
        @department = session[:department]
        session[:department] = nil
        
        @department.update(params.require(:department).permit(:name))
        @department.valid?
    
    rescue => e 
        flash[:danger] = e.message
        render :edit
    end
    
    def destroy
        @department = Department.find(params[:id])
        @department.users do |user|
            puts user
            user.destroy
        end
        i = User.last.EmployeeID
        ActiveRecord::Base.connection.execute("ALTER TABLE users AUTO_INCREMENT = #{(i)}") #in case any users are destroyed 
        
        @department.destroy
        
        i = Department.last.id
        ActiveRecord::Base.connection.execute("ALTER TABLE departments AUTO_INCREMENT = #{(i)} ") #resets the auto-increment function to the previous largest ie the last ID
    
        flash[:success] = "Department sucessfully destroyed"
        redirect_to departments_path, status: :see_other
  
    rescue => e 
        flash[:danger] = e.message
        redirect_to @department, status: :see_other
    end 
end