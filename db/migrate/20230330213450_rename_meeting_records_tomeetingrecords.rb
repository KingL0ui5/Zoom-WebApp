class RenameMeetingRecordsTomeetingrecords < ActiveRecord::Migration[5.0]
  def change
    rename_table :none, :meetingrecords
  end
end
