class AddDefaultStartTimeToMeetingRecords < ActiveRecord::Migration[5.0]
  def change
    change_column :meetingrecords, :start_time, :datetime, null: true
  end
end
