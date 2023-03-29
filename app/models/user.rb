class User < ActiveRecord::Base 
    belongs_to :department 
    
    validates :Name, :EmailAddress, :department_id, :password, presence: { message: "This field cannot be empty" }
    
    validates :EmailAddress, confirmation: {case_sensitive: false, message: "Email addresses do not match"},
                             format: {with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "This is not a valid email address"}, #regex for email address
                             uniqueness: { message: "This Email Address is already in use" }
    
    validates :EmailAddress_confirmation, presence: {message: "This field cannot be empty"} 
    
    #validations for each field in the creation of a new user model
    has_secure_password
    validates :password, length: { minimum: 6, message: "The password must be at least 6 characters in length" }
    validates :password_confirmation, presence: { message: "This field cannot be empty" }

#User password. Only used for the "autoCreate" function. The password has to have a minimum of 8 characters and maximum of 32 characters. By default (basic requirement), password must have at least one letter (a, b, c..), at least one number (1, 2, 3...) and include both uppercase and lowercase letters. It should not contain only one identical character repeatedly ('11111111' or 'aaaaaaaa') and it cannot contain consecutive characters ('12345678' or 'abcdefgh').

end 