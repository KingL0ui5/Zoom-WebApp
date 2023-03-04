class Department < ActiveRecord::Base
    has_many :users
    
    validates :name, presence: {message: "this field cannot be blank"}
end
