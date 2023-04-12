class DepartmentsController < ApplicationController
    before_action :check_if_logged_in, only: [:edit, :update, :new, :create, :destroy] #ensures that user is logged in first
    
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
    
    def edit 
        @department = Department.find(params[:id])
    end 
    
    def update
        @department = Department.find(params[:id])
        @department.update(params.require(:department).permit(:name))
        
        if !@department.valid?
            render :edit
        else
            flash[:success] = "Changes saved"
            redirect_to @department
        end
    end
    
    def destroy
        @department = Department.find(params[:id])
        
        @department.users.each do |user| 
            user.destroy #invokes destroy method in the controller 
        end
        
        @department.meetingrecords.destroy_all
        @department.delete
        
        i = Department.last.id
        ActiveRecord::Base.connection.execute("ALTER TABLE departments AUTO_INCREMENT = #{(i)} ") #resets the auto-increment function to the previous largest ie the last ID
    
        flash[:success] = "Department sucessfully destroyed"
        redirect_to departments_path, status: :see_other
  
    rescue => e 
        flash[:danger] = e.message
        redirect_to @department, status: :see_other
    end 
end