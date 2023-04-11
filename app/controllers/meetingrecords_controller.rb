class MeetingrecordsController < ApplicationController
  before_action :check_if_logged_in
  
  def index
    @records = Meetingrecord.order(start_time: :desc ).all
  end
end
