class UpdatePrepaid < ActiveRecord::Migration[5.1]
  def up
    create_table :update_prepaid do |t|
      t.string :customer_id
      t.string :order_id
      t.string :title
      t.datetime :scheduled_at
      t.boolean :is_updated, default: false
      t.datetime :updated_at
      

    end
  end

  def down
    drop_table :update_prepaid
  end
end
