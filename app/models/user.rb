class User < ApplicationRecord
    validates :EmployeeID, :Name, :EmailAddress, :Department, presence: { message: "This field cannot be blank" }
    
    validates :EmployeeID, uniqueness: {message: "Employee already exists."}, format: {with: /\A[+-]?\d+\z/, message: "This is not a valid Employee ID"}, length: { is: 4, message: "This is not a valid Employee ID" } 
    
    validates :EmailAddress, confirmation: {case_sensitive: false, message: "Email addresses do not match"}, format: {with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i , message: "This is not a valid email address"} #regex for email address
    
    validates :EmailAddress_confirmation, presence: {message: "This field cannot be blank"}

    #validates :Department, if: :dept_exits?
    
    #criteria to accept generation of new user

    def dept_exits?
       Department == "test"  #list of departments
    end 
end 