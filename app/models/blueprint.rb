class Blueprint < ActiveRecord::Base
  has_many :blueprint_inventories
  belongs_to :item_group
  has_many :blueprint_skills
  has_many :blueprint_materials
  belongs_to :item_type, :foreign_key => 'product_item_id'
  has_many :corp_orders, :primary_key => 'product_item_id', :foreign_key => 'item_type_id' do
    # TODO move this to market transactions & latest sell
    def latest_sell_order
      find(:first, :order => 'issued DESC', :conditions => {:item_type_id => proxy_owner.product_item_id})
    end
  end
  has_many :market_datas, :primary_key => 'product_item_id', :foreign_key => 'item_type_id' do
    def lowest_sell_per_hub
      connection.select_all("SELECT 
        trade_hubs.id, 
        (
          SELECT 
            id 
          FROM market_datas 
          WHERE station_id = trade_hubs.id 
          AND item_type_id = #{proxy_owner.product_item_id} 
          AND order_type = 'sell' 
          AND DATE_SUB(CURDATE(), INTERVAL 15 DAY) <= order_placed_at
          ORDER BY DATE(order_placed_at) DESC, price DESC
          LIMIT 1
        ) AS market_data_id 
        FROM trade_hubs").map {|row|
          MarketData.find(row['market_data_id']) if row['market_data_id'] 
        }.compact
    end
  end

  # TODO uses wrong data tbh
  def last_sell_price
    order = corp_orders.latest_sell_order

    return order.price if order
    0.0
  end

  def run_cost(me_level=0)
    blueprint_materials.map {|material| material.cost(me_level) }.inject {|a,b| a + b}
  end # run_cost

  # Unit cost for things like ammo - 100 units per run, but you set the market
  # order up with a per-unit price...
  def unit_cost(me_level=0)
    run_cost(me_level) / product_batch_quantity
  end # unit cost

  # Perfect ME for this blueprint. This will be the highest
  # value from all the mats.
  def perfect_material_efficiency
    blueprint_materials.map(&:perfect_material_efficiency).sort.last
  end # end perfect_material_efficiency
end
