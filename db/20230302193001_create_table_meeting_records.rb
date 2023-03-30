class CreateTableMeetingRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :MeetingRecords, id: :integer do |t|
      t.string :zoom_meeting_id, null: false
      t.datetime :start_time, null: false 
      t.integer :duration, null: false
      t.string :type, null: false 
      t.references :user, foreign_key: true #host
      t.references :department, foreign_key: true #participants
      t.timestamps
    end
    
    execute <<-SQL
      ALTER TABLE meetingRecords ADD PRIMARY KEY (MeetingID);
    SQL
  end
end
