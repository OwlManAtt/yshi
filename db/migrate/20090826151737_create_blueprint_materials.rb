class CreateBlueprintMaterials < ActiveRecord::Migration
  def self.up
    create_table :blueprint_materials do |t|
      t.integer :blueprint_id, :null => false
      t.integer :material_type_id, :null => false
      t.string :material_name, :limit => 80, :null => false
      t.integer :quantity, :null => false
      t.decimal :damage_per_job, :null => false, :precision => 5, :scale => 2
    end

    add_index :blueprint_materials, :blueprint_id
    add_index :blueprint_materials, :material_type_id
  end

  def self.down
    drop_table :blueprint_materials
  end
end
