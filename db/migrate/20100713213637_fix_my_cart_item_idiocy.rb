class FixMyCartItemIdiocy < ActiveRecord::Migration
  def self.up
    rename_column :cart_items, :blueprint_id, :blueprint_inventory_id
  end

  def self.down
    rename_column :cart_items, :blueprint_inventory_id, :blueprint_id
  end
end
