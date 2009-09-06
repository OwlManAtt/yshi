class CreateItemTypes < ActiveRecord::Migration
  def self.up
    create_table :item_types, :id => false do |t|
      t.integer :id, :null => false
      t.string :name, :limit => 80, :null => false
      t.integer :item_group_id, :null => false
    end
    
    add_index :item_types, :item_group_id
    execute "ALTER TABLE `item_types` CHANGE COLUMN `id` `id` int(11) NOT NULL PRIMARY KEY"
  end

  def self.down
    drop_table :item_types
  end
end
