class RemoveIdFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :id
  end
end
