class AddWasteFactorToBlueprints < ActiveRecord::Migration
  def self.up
    add_column :blueprints, :waste_factor, :integer
  end

  def self.down
    remove_column :blueprints, :waste_factor
  end
end
