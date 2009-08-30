class CreateTradeHubs < ActiveRecord::Migration
  def self.up
    create_table :trade_hubs, :id => false do |t|
      t.integer :id, :null => false # Non-auto incrementing
      t.string :station_name, :limit => 80, :null => false  
    end

    execute "ALTER TABLE `trade_hubs` CHANGE COLUMN `id` `id` int(11) NOT NULL PRIMARY KEY"
  end

  def self.down
    drop_table :trade_hubs
  end
end
