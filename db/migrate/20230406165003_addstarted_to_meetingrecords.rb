class AddstartedToMeetingrecords < ActiveRecord::Migration[5.0]
  def change
    add_column :meetingrecords, :started, :boolean, default: false
  end
end
