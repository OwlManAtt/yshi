class AddPricePollFlagToItemGroups < ActiveRecord::Migration
  def self.up
    add_column :item_groups, :poll_price, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :item_groups, :poll_price
  end
end
