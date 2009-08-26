class CreateBlueprintSkills < ActiveRecord::Migration
  def self.up
    create_table :blueprint_skills do |t|
      t.integer :blueprint_id, :null => false
      t.integer :skill_type_id, :null => false
      t.string :skill_name, :null => false, :limit => 80
      t.integer :level, :null => false
    end

    add_index :blueprint_skills, :blueprint_id
    add_index :blueprint_skills, :skill_type_id
  end

  def self.down
    drop_table :blueprint_skills
  end
end
