class CartController < ApplicationController
  
  def list 
    @carts = Cart.find(:all)
  end # list

  def detail
    @cart = Cart.find(params[:id])
    @material_stats = {
      :volume_m3 => @cart.materials.map {|m| m['volume_per_unit'] * m['quantity'] }.sum,
      :cost => @cart.materials.map {|m| m['price_per_unit'] * m['quantity'] }.sum
    }
    @product_stats = {
      :volume_m3 => @cart.cart_items.map {|item| item.blueprint_inventory.blueprint.item_type.volume_m3 * item.quantity }.sum,
      # Not useful TBH - matches raw material cost.
      # :cost => @cart.cart_items.map {|item| item.blueprint_inventory.blueprint.run_cost(item.blueprint_inventory.material_efficiency) * item.quantity }.sum
    }

    #@total_volume = @cart.materials.map {|m| m['volume_per_unit'] * m['quantity'] }.sum
    #@total_material_cost = @cart.materials.map {|m| m['price_per_unit'] * m['quantity'] }.sum
  end

  def add_item
    @cart = Cart.find(params[:cart][:cart_id])
    @cart.cart_items << CartItem.new({
      :cart_id => @cart.id, 
      :blueprint_inventory_id => params[:blueprint_id],
      :quantity => params[:quantity],
    })

    if @cart.save
      flash[:notice] = 'Successfully added to cart!'
      redirect_to :action => 'detail', :id => @cart
    else
      render :status => 500 
    end
  end # add_item
end
