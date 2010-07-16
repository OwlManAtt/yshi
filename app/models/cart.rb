class Cart < ActiveRecord::Base
  has_many :cart_items

  def materials
    material_list = Hash.new()

    cart_items.each do |item| 
      item.blueprint_inventory.blueprint.blueprint_materials.each do |material| 
        qty = material.quantity(item.blueprint_inventory.material_efficiency) * item.quantity 

        if material_list.has_key?(material.material_type_id)
          material_list[material.material_type_id]['quantity'] += qty
        else
          material_list[material.material_type_id] = {
            'quantity' => qty,
            'name' => material.material_name,
            'volume_per_unit' => material.item_type.volume_m3,
            'price_per_unit' => material.material_prices.current.price,  
          }
        end

      end
    end    
    
    # A hash above for efficiency, but now we want an array with the
    # material in the greatest quality first.
    material_list.map { |k,v| v }.sort { |a,b| b['quantity'] <=> a['quantity'] }
  end # materials
end
