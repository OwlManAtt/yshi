class CorpOrder < ActiveRecord::Base
  belongs_to :blueprint, :primary_key => 'product_item_id', :foreign_key => 'item_type_id'
  belongs_to :item_type, :foreign_key => 'item_type_id' 
  has_one :trade_hub, :primary_key => 'station_id', :foreign_key => 'id'

  def self.find_latest_sell_orders
    find(:all, :order => 'issued DESC', :conditions => {:order_type => 'sell'}, :limit => 5)
  end

  def self.activity_summary
    ["SELECT 
        'Ice Mining' AS activity,
        SUM((price * volume_entered)) AS income
      FROM corp_orders 
      INNER JOIN item_types ON corp_orders.item_type_id = item_types.id 
      WHERE corp_orders.order_type = 'sell'
      AND item_types.item_group_id IN (423)
      AND DATE_SUB(CURDATE(),INTERVAL 30 DAY) <= corp_orders.issued",

    "SELECT 
        'Manufacturing' AS activity,
        SUM((price * volume_entered)) AS income
      FROM corp_orders 
      INNER JOIN item_types ON corp_orders.item_type_id = item_types.id 
      WHERE corp_orders.order_type = 'sell'
      AND item_types.item_group_id NOT IN (423)
      AND DATE_SUB(CURDATE(),INTERVAL 30 DAY) <= corp_orders.issued"
    ].inject({}) do |hash, query|
      result = ActiveRecord::Base.connection.select_all(query).first
      hash[result['activity']] = result['income'].to_f

      hash
    end # query lewp
  end # self.activity_summary

  def total_value
    (price * volume_entered)
  end

  def profit_per_unit
    return price unless unit_material_cost > 0
    (price - unit_material_cost)
  end

  def margin
    return 100 unless unit_material_cost > 0
    (profit_per_unit / unit_material_cost) * 100
  end
end # CorpOrder
