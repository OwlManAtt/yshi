class CreateCorpOrders < ActiveRecord::Migration
  def self.up
    create_table :corp_orders do |t|
      t.integer :order_id, :null => false
      t.integer :station_id, :null => false
      t.integer :volume_entered, :null => false
      t.integer :volume_remaining, :null => false
      t.integer :minimum_volume, :null => false
      t.string :order_state, :null => false, :limit => 20
      t.integer :item_type_id, :null => false
      t.integer :range, :null => false
      t.integer :wallet_division, :null => false
      t.integer :duration_days, :null => false
      t.decimal :escrow, :precision => 20, :scale => 2, :null => false
      t.decimal :price, :precision => 20, :scale => 2, :null => false
      t.string :order_type, :limit => 4, :null => false
      t.datetime :issued, :null => false
      t.decimal :unit_material_cost, :precision => 20, :scale => 2
      t.timestamps
    end

    add_index :corp_orders, :order_id
    add_index :corp_orders, :station_id
    add_index :corp_orders, :item_type_id
  end

  def self.down
    drop_table :corp_orders
  end
end
