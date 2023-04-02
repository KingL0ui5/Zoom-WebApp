class RenamenoneTomeetingrecords < ActiveRecord::Migration[5.0]
  def up
    rename_table :none, :meetingrecords
  end
end
