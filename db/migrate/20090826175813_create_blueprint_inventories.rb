class CreateBlueprintInventories < ActiveRecord::Migration
  def self.up
    create_table :blueprint_inventories do |t|
      t.integer :item_id
      t.integer :blueprint_id, :null => false
      t.integer :material_efficiency, :null => false
      t.integer :production_efficiency, :null => false 
      t.decimal :price, :precision => 18, :scale => 2, :null => false
      t.timestamps
    end

    add_index :blueprint_inventories, :blueprint_id
    add_index :blueprint_inventories, :item_id 
  end

  def self.down
    drop_table :blueprint_inventories
  end
end
