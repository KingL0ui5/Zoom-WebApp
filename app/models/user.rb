class User < ActiveRecord::Base 
    belongs_to :department 
    has_many :meetingrecords, foreign_key: "EmployeeID", dependent: :destroy
    
    validates :Name, :EmailAddress, :department_id, presence: { message: "This field cannot be empty" }
    
    validates :EmailAddress, confirmation: {case_sensitive: false, message: "Email addresses do not match"},
                             format: {with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "This is not a valid email address"}, #regex for email address
                             uniqueness: { message: "This Email Address is already in use" }
    
    validates :EmailAddress_confirmation, presence: {message: "This field cannot be empty"} 
    
    password_requirements = /\A
      (?=.*\d)                # Must contain a digit
      (?=.*[a-z])             # Must contain a lowercase letter
      (?=.*[A-Z])             # Must contain an uppercase letter
      (?=.*[^\w\s])           # Must contain a special character
      (?!.*(.)(\1){7})        # Must not contain a single repeated character
      (?!.*([a-zA-Z]){4})     # Must not contain four consecutive letters
      (?!.*(\d){4})           # Must not contain four consecutive digits
      (?!.*([^\w\s]){2})      # Must not contain two consecutive special characters
      [a-zA-Z\d\W]{8,32}      # Must be between 8 and 32 characters, can contain any non-whitespace character
    \z/x

    has_secure_password
    validates :password, format: { with: password_requirements, message: "Min: 8 chars, max: 32 chars. Password must have at least one letter, at least one number (1, 2, 3...) and include uppercase and lowercase letters. It should not contain only one identical character repeatedly and it cannot contain consecutive characters" }
    validates :password_confirmation, presence: { message: "This field cannot be empty" }
end 