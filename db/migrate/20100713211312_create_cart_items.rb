class CreateCartItems < ActiveRecord::Migration
  def self.up
    create_table :cart_items do |t|
      t.integer :cart_id, :null => false
      t.integer :blueprint_id, :null => false
      t.integer :quantity, :null => false, :default => 1
    end

    add_index :cart_items, :cart_id
    add_index :cart_items, :blueprint_id
  end

  def self.down
    drop_table :cart_items
  end
end
