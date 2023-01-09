class CreateDepartments < ActiveRecord::Migration[5.0]
  def change
    create_table :departments do |t|
      t.string :name

      t.timestamps
    
    create_table :users do |t|
      t.integer :EmployeeID
      t.string :Name
      t.string :EmailAddress

      t.timestamps
    end
  end
end
