class ChangeUsersPrimaryKey < ActiveRecord::Migration[5.0]
  def up
    change_column :users, :EmployeeID, :integer, auto_increment: true, null: false
    execute "ALTER TABLE users ADD PRIMARY KEY (EmployeeID);"
  end

  def down
    execute "ALTER TABLE users DROP PRIMARY KEY, ADD PRIMARY KEY (id);"
    change_column :users, :EmployeeID, :integer, auto_increment: true, null: true
  end
end