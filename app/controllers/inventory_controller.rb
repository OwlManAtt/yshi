class InventoryController < ApplicationController
  def new 
    @bp_type = Blueprint.find(params[:id])
    @blueprint_inventory = BlueprintInventory.new
  end

  def create
    @blueprint_inventory = BlueprintInventory.new(params[:blueprint_inventory])
    if @blueprint_inventory.save
      flash[:notice] = "Blueprint added to inventory."
      redirect_to :action => 'list'
    else
      @bp_type = Blueprint.find(params[:blueprint_inventory][:blueprint_id])
      render :action => 'new'
    end
  end

  def list
    @inventory =  BlueprintInventory.find(:all, :joins => :blueprint, :order => 'blueprints.blueprint_name DESC') 
  end
end
