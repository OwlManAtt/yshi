class FixBlueprintGroupName < ActiveRecord::Migration
  def self.up
    rename_column :blueprints, :group_id, :item_group_id
  end

  def self.down
    rename_column :blueprints, :item_group_id, :group_id
  end
end
