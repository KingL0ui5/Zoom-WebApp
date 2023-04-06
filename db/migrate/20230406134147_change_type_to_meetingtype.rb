class ChangeTypeToMeetingtype < ActiveRecord::Migration[5.0]
  def change
    rename_column :meetingrecords, :type, :meeting_type
  end
end
