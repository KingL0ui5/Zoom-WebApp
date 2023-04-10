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
        puts "new"
        @department = Department.new
    end 
    
    def create 
        puts "creating"
        @department = Department.new(params.require(:department).permit(:name))
        @department.save!
        flash[:success] = "Department created successfully"
        redirect_to @department
        
    rescue => e
        flash[:danger] = e.message
        render :new
    end
    
    def edit #FIX
        puts "editing"
        @department = Department.find(params[:id])
    end 
    
    def update
        puts "updating"
        @department = Department.find(params[:id])
        @department.update(params.require(:department).permit(:name))
        
        if !@department.valid?
            render :edit
        end
        flash[:success] = "Changes saved"
        redirect_to @department
    end
    
    def destroy
        @department = Department.find(params[:id])
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