class Meetingrecord < ActiveRecord::Base
  has_one :user, foreign_key: :EmployeeID #host
  has_one :department, foreign_key: :department_id #participants
end