class TradeHub < ActiveRecord::Base
  belongs_to :corp_orders, :primary_key => 'station_id', :foreign_key => 'id'
end
