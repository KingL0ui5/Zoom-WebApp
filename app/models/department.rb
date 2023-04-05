class Department < ActiveRecord::Base
    has_many :users, dependent: :destroy #will destroy all existing users
    belongs_to :meetingrecord
    
    validates :name, presence: {message: "this field cannot be empty"}
end
