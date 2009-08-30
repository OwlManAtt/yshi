class MarketData < ActiveRecord::Base
  belongs_to :blueprint, :primary_key => 'product_item_id', :foreign_key => 'item_type_id'

  def margin(cost)
    (profit(cost) / cost * 100)
  end # margin

  def profit(cost)
    (price - cost)
  end # profit
end
