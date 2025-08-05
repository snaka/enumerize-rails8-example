class ChangeStatusToIntegerInUsers < ActiveRecord::Migration[8.0]
  def up
    # Add temporary column
    add_column :users, :status_temp, :integer
    
    # Migrate existing data
    execute <<-SQL
      UPDATE users 
      SET status_temp = CASE 
        WHEN status = 'active' THEN 0
        WHEN status = 'inactive' THEN 1
        WHEN status = 'suspended' THEN 3
        ELSE 0
      END
    SQL
    
    # Remove old column and rename new one
    remove_column :users, :status
    rename_column :users, :status_temp, :status
    
    # Set default value
    change_column_default :users, :status, 0
  end

  def down
    # Add temporary string column
    add_column :users, :status_temp, :string
    
    # Migrate data back
    execute <<-SQL
      UPDATE users 
      SET status_temp = CASE 
        WHEN status = 0 THEN 'active'
        WHEN status = 1 THEN 'inactive'
        WHEN status = 3 THEN 'suspended'
        ELSE 'active'
      END
    SQL
    
    # Remove integer column and rename string one
    remove_column :users, :status
    rename_column :users, :status_temp, :status
  end
end
