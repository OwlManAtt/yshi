class CreateBlueprints < ActiveRecord::Migration
  def self.up
    # Note regarding these tables - the :id => false is a hack so I can
    # prevent it from creating an auto_increment column. These are lookup
    # tables that will be magically populated off of the EVE DB exports,
    # and I desire to use their DB IDs as PKs (which will probably bite me
    # in the ass two years down the road, but whatever).

    create_table :item_groups, :id => false do |t|
      t.integer :id, :null => false
      t.string :group_name, :null => false, :limit => 60
    end

    create_table :blueprints, :id => false do |t|
      t.integer :id, :null => false
      t.integer :group_id, :null => false
      t.string :blueprint_name, :null => false, :limit => 80
      t.decimal :base_price, :precision => 18, :scale => 2, :null => false
      t.integer :tech_level, :null => false
      t.integer :production_limit, :null => false

      t.integer :product_item_id, :null => false
      t.string :product_name, :null => false, :limit => 80
      t.integer :product_batch_quantity, :null => false
    end
   
    add_index :blueprints, :group_id

    # Haaack. See above.
    execute "ALTER TABLE `item_groups` CHANGE COLUMN `id` `id` int(11) NOT NULL PRIMARY KEY"
    execute "ALTER TABLE `blueprints` CHANGE COLUMN `id` `id` int(11) NOT NULL PRIMARY KEY"
  end

  def self.down
    drop_table :blueprints
    drop_table :item_groups
  end
end
