class CreateMaterialPrices < ActiveRecord::Migration
  def self.up
    create_table :material_prices do |t|
      t.integer :item_type_id, :null => false
      t.boolean :archived, :default => false, :null => false
      t.decimal :price, :precision => 18, :scale => 2, :null => false
      t.datetime :created_at
    end

    add_index :material_prices, :item_type_id
  end

  def self.down
    drop_table :material_prices
  end
end
