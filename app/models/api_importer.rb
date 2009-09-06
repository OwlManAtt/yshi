require 'eaal'

class APIImporter
  class MarketLog
    @@order_states = {
      0 => 'open',
      1 => 'closed',
      2 => 'expired',
      3 => 'cancelled',
      4 => 'pending',
      5 => 'invalid',
    }

    def initialize(userId,apiKey,charId)
      path = File.join(RAILS_ROOT,'tmp','eaal_cache')
      EAAL.cache = EAAL::Cache::FileCache.new(path)

      @api = EAAL::API.new(userId,apiKey)
      @api.scope = 'corp'
      @char_id = charId
    end

    def update
      @api.marketOrders({'characterId' => @char_id}).orders.each do |order|
        # Do we have this BP? If so, log the approximate cost for one unit at
        # (more or less) the time the order is created.
        bp = BlueprintInventory.find(:first, :joins => :blueprint, :conditions => ['blueprints.product_item_id = ?', order.typeID])
        cost = bp.blueprint.unit_cost(bp.material_efficiency) if bp 

        values = {
          :order_id => order.orderID, 
          :station_id => order.stationID,
          :volume_entered => order.volEntered,
          :volume_remaining => order.volRemaining,
          :minimum_volume => order.minVolume,
          :order_state => @@order_states[order.orderState.to_i],
          :item_type_id => order.typeID,
          :range => order.range,
          :wallet_division => order.accountKey,
          :duration_days => order.duration,
          :escrow => order.escrow,
          :price => order.price,
          :order_type => (order.bid.to_i == 0) ? 'sell' : 'buy',
          :issued => order.issued.to_time,
          :unit_material_cost => cost,
        } # values hash

        row = spawn_order(order.orderID)
        row.attributes = values
        row.save!
      end # loop

      return true
    end # update

    private
    # The API is awesome and recyles orderIds. So, this will tell us if
    # the orderID in question has had an order opened in the last 90 days.
    # If it has, we'll load that order row. If it hasn't, we'll create a new
    # row for it.
    def spawn_order(order_id)
      order = CorpOrder.find(:first, :conditions => ['order_id = ? AND issued >= ?', order_id, Time.now.ago(90.days)])

      order ||= CorpOrder.new()
    end # new_order_id 
  end # marketlog
end # impoerter
