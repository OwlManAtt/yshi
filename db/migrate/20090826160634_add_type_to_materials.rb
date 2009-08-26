class AddTypeToMaterials < ActiveRecord::Migration
  def self.up
    add_column :blueprint_materials, :material_type, :string, :limit => 10, :null => false 
  end

  def self.down
    remove_column :blueprint_materials, :material_type
  end
end
