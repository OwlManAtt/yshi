class AddItemGroupIdToBlueprintMaterials < ActiveRecord::Migration
  def self.up
    add_column :blueprint_materials, :item_group_id, :integer, :null => false
    add_index :blueprint_materials, :item_group_id
  end

  def self.down
    remove_column :blueprint_materials, :item_group_id
  end
end
