class Meetingrecord < ActiveRecord::Base
  has_one :user #host
  has_one :department #participants
end