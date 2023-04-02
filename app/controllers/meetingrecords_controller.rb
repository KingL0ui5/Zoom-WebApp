class MeetingrecordsController < ApplicationController
  def index
    @records = Meetingrecord.all
  end
end
