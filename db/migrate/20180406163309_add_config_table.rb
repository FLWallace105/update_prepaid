class AddConfigTable < ActiveRecord::Migration[5.1]
  def up
    create_table :update_prepaid_config do |t|
      t.string :title
      t.string :product_id
      t.string :variant_id
      t.string :product_collection
      
      

    end
  end

  def down
    drop_table :update_prepaid_config
  end
end
