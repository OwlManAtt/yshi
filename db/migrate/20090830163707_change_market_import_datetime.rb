class ChangeMarketImportDatetime < ActiveRecord::Migration
  def self.up
    change_column :market_log_import, :issued, :string, :limit => 40, :null => false
    change_column :market_log_import, :reportedby, :string, :limit => 40, :null => false

    add_column :market_datas, :market_order_id, :integer, :null => false
    add_index :market_datas, :market_order_id, :unique => true
  end

  def self.down
    change_column :market_log_import, :issued, :datetime, :null => false
    change_column :market_log_import, :reportedby, :datetime, :null => false
    drop_column :market_datas, :market_order_id
  end
end
