class DepartmentsController < ApplicationController
    def index
        @departments = Department.all
    end 
    
    def show
        begin
            @department = Department.find(params[:id])
            @users = @department.users
        rescue => e 
            redirect_to department_path, flash: { error: (e.message) }#displays error passed by ruby
        end
    end
    
    def new
        @department = Department.new
    end 
    
    def create 
        begin 
            @department = Department.new(params.require(:department).permit(:name))
            @department.save!
            redirect_to @department, flash: { success: "Department sucessfully created" }
        rescue => e
            render :new, flash: { error: (e.message) }
        end
    end
    
    def update
        @department = Department.find([params(:id)])
        @Department.update(:name)
        redirect_to @Department
        
    rescue => e 
        redirect_to department_path, flash: { error: e.message } 
    end
    
    def destroy
    
        @department = Department.find(params[:id])
        @department.destroy
        
        i = Department.last.id
        ActiveRecord::Base.connection.execute("ALTER TABLE departments AUTO_INCREMENT = #{(i)} ") #resets the auto-increment function to the previous largest ie the last ID
    
        redirect_to @department, status: :see_other, flash: { success: "Department sucessfully destroyed" }  #sucess (400 ok)
        
    rescue ActiveRecord::RecordNotFound #department cannot be found 
        redirect_to department_path, status: :see_other, flash: { error: "Department does not exist" }

    rescue ActiveRecord::RecordNotDestroyed #department not being destroyed 
        redirect_to @department, status: :see_other, flash: { error: "Department could not be destroyed, please try again" } 
    end 
    
end