class CreateMarketDatas < ActiveRecord::Migration
  def self.up
    create_table :market_datas do |t|
      t.integer :item_type_id, :null => false
      t.string :order_type, :limit => 4, :null => false
      t.decimal :price, :precision => 20, :scale => 2, :null => false
      t.datetime :order_placed_at, :null => false
      t.integer :station_id, :null => false
      t.string :station_name, :limit => 80, :null => false
    end

    add_index :market_datas, :item_type_id
    add_index :market_datas, :station_id
  end

  def self.down
    drop_table :market_datas
  end
end
