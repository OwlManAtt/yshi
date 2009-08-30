class AddMarketLog < ActiveRecord::Migration
  def self.up
    create_table :market_log_import do |t|
      t.integer :order_id, :null => false
      t.integer :region_id, :null => false
      t.integer :systemid, :null => false
      t.integer :station_id, :null => false
      t.integer :type_id, :null => false
      t.decimal :bid, :precision => 20, :scale => 2, :null => false
      t.decimal :price, :precision => 20, :scale => 2, :null => false
      t.integer :minvolume, :null => false
      t.integer :volremain, :null => false
      t.integer :volenter, :null => false
      t.datetime :issued, :null => false
      t.string :duration, :null => false, :limit => 16
      t.integer :range, :null => false
      t.integer :reportedby, :null => false
      t.datetime :reportedtime, :null => false
    end

    add_index :market_log_import, :region_id
    add_index :market_log_import, :systemid
    add_index :market_log_import, :station_id
    add_index :market_log_import, :type_id
  end

  def self.down
    drop_table :market_log_import 
  end
end
