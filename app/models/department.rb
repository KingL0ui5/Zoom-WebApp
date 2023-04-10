class Department < ActiveRecord::Base
    has_many :users, dependent: :destroy #will destroy all existing users
    has_many :meetingrecords, foreign_key: "EmployeeID", dependent: :destroy
    
    validates :name, presence: {message: "this field cannot be empty"}
end
