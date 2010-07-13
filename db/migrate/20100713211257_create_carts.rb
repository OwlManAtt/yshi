class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
      t.string :name, :null => false, :limit => 40
      t.integer :assigned_user_id, :null => false, :default => 0 
    end

    add_index :carts, :assigned_user_id
  end

  def self.down
    drop_table :carts
  end
end
