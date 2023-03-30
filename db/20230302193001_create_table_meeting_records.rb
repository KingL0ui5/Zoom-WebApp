class CreateTableMeetingRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :meetingrecords, primary_key: 'meeting_id' do |t|
      t.string :zoom_meeting_id, null: false
      t.datetime :start_time, null: false 
      t.integer :duration, null: false
      t.string :type, null: false 
      t.references :department, foreign_key: true, index: true #participants
      t.integer :EmployeeID #host
      
      t.index :EmployeeID
      t.foreign_key :users, column: :EmployeeID, primary_key: :EmployeeID
      
      t.timestamps
    end
  end
end
