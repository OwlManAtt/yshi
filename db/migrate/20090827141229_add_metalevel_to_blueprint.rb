class AddMetalevelToBlueprint < ActiveRecord::Migration
  def self.up
    add_column :blueprints, :meta_level, :integer, :null => false, :default => 0 
  end

  def self.down
    remove_column :blueprints, :meta_level
  end
end
