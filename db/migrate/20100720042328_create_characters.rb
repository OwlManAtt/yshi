class CreateCharacters < ActiveRecord::Migration
  def self.up
    create_table :characters do |t|
      t.integer :api_user_id, :null => false
      t.string :api_full_key, :null => false, :limit => 64
      t.integer :api_character_id, :null => false
      t.boolean :active, :default => false
    end
  end

  def self.down
    drop_table :characters
  end
end
