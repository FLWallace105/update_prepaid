class AddFieldUpdatePrepaid < ActiveRecord::Migration[5.1]
  def up
    add_column :update_prepaid, :properties, :text
    
  end

  def down
    remove_column :update_prepaid, :properties, :text
    
  end
end
