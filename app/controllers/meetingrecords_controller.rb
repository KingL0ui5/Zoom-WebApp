class MeetingrecordsController < ApplicationController
  def index
    @records = Meetingrecord.order(start_time: :desc ).all
  end
end
