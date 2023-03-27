class CreateTableMeetingRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :MeetingRecords, id: :integer do |t|
      t.datetime :StartTime, null: false 
      t.datetime :Endtime, null: false
      t.references :user, foreign_key: true
      t.timestamps
    end
    
    execute <<-SQL
      ALTER TABLE meetingRecords ADD PRIMARY KEY (MeetingID);
    SQL
  end
end
