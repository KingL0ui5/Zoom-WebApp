class DepartmentsController < ApplicationController
    def index
        @departments = Department.all
    end 
    
    def show
        @department = Department.find(params[:id])
    end
    
    def new
        @department = department.new
    end 
    
    def create 
        @department = Department.new(:name)
        if @Department.save
            redirect_to @Department, notice: "Department was sucessfully created"
        else 
            render :new, status: :unprocessable_entity
        end
    end
    
    def update
        @department = Department.find([params(:id)])
        
        if @Department.update(:name)
            redirect_to @Department
        else 
            render @edit, status: :unprocessable_entity
        end
    end
    
    def destroy 
        @department = Department.find(params[:id])
        @department.destroy
        
        redirect_to root_path, status: :see_other, notice: "Department was sucessfully destroyed"
    end 
    
end