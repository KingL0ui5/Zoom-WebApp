class User < ActiveRecord::Base
    belongs_to :department, foreign_key: true 
    
    validates :Name, :EmailAddress, :Department, presence: { message: "This field cannot be blank" }
    
   # validates :EmployeeID, uniqueness: {message: "Employee already exists."}, format: {with: /\A\d{4}\z/, message: "This is not a valid Employee ID"}, if: -> {:EmployeeID.present?}  #regex for 4 digits
    
    validates :EmailAddress, confirmation: {case_sensitive: false, message: "Email addresses do not match"}, format: {with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i , message: "This is not a valid email address"} #regex for email address
    
    validates :EmailAddress_confirmation, presence: {message: "This field cannot be blank"} 
    
    #validations for each field in the creation of a new user model
end 