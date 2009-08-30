class BlueprintMaterial < ActiveRecord::Base
  belongs_to :blueprint
  belongs_to :item_group
  has_many :material_prices, :primary_key => 'material_type_id', :foreign_key => 'item_type_id' do

    # Pick the current row. If no unarchived rows exist, a dummy price object
    # will be returned with 0.00 as the price.
    def current
      price = find :first, :conditions => {:archived => false}, :order => 'created_at DESC'
      
      return price unless price.nil?

      # I can't find any documentation on this, but proxy_owner refers to the actual instance of
      # the class we're in...
      MaterialPrice.new(:item_type_id => proxy_owner.material_type_id, :price => 0.00, :archived => false, :created_at => Time.now)
    end # current_price
  end

  # Get the perfect ME needed to eliminate waste for this one single material.
  def perfect_material_efficiency
    (0.02 * self.blueprint.waste_factor * quantity).ceil
  end # perfect_material_efficiency

  def waste(me_level=0)
    if me_level >= 0 # Normal BPs
      waste = (quantity * (blueprint.waste_factor.to_f / 100) * (1.to_f / (me_level + 1))).round
    elsif me_level < 0 # Invented T2 BPCs
      waste = (quantity * (blueprint.waste_factor.to_f / 100) * (1 - me_level)).round
    end
  end # waste

  def waste_cost(me_level=0)
    material_prices.current.price * waste(me_level)    
  end # waste_cost

  def cost(me_level=0)
    material_quantity = quantity + waste(me_level)  
    return (material_prices.current.price * material_quantity)
  end # end cost

  def quantity(me_level=0)
    if me_level == 0
      return read_attribute('quantity')
    else
      return read_attribute('quantity') + waste(me_level)
    end
  end # quantity
end
