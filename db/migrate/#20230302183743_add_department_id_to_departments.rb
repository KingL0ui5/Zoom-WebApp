class AddDepartmentIdToDepartments < ActiveRecord::Migration[5.0]
  def up
    change_column :departments, :id, :integer, auto_increment: false, null: false
    add_column :departments, :departmentID, :integer, null: false, auto_increment: true
    execute <<-SQL
      ALTER TABLE departments ADD PRIMARY KEY (departmentID);
    SQL
    
    remove_column :departments, :id
  end

  def down
    execute <<-SQL
      ALTER TABLE departments DROP PRIMARY KEY;
    SQL
    remove_column :departments, :departmentID
  end
end
