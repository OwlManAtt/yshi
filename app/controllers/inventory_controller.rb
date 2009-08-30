class InventoryController < ApplicationController
  def new 
    @bp_type = Blueprint.find(params[:id])
    @blueprint_inventory = BlueprintInventory.new
  end

  def create
    @blueprint_inventory = BlueprintInventory.new(params[:blueprint_inventory])
    if @blueprint_inventory.save
      flash[:notice] = "The blueprint added to inventory."
      redirect_to :action => 'list'
    else
      @bp_type = Blueprint.find(params[:blueprint_inventory][:blueprint_id])
      render :action => 'new'
    end
  end

  def edit
    @item = BlueprintInventory.find(params[:id])
    @blueprint = @item.blueprint 
  end # edit

  def save
    @item = BlueprintInventory.find(params[:id])
    @item.attributes = params[:blueprint_inventory] 
    if @item.save
      flash[:notice] = "The blueprint has been updated."
      redirect_to :action => 'detail', :id => @item.id
    else
      @blueprint = @item.blueprint
      render :action => 'edit'
    end

  end # save

  def list
    @inventory =  BlueprintInventory.find(:all, :joins => :blueprint, :order => 'blueprints.blueprint_name') 
  end # list

  def detail
    @item = BlueprintInventory.find_by_id(params[:id]) 
    @blueprint = @item.blueprint
    @materials = @item.blueprint.blueprint_materials
    @skills = @item.blueprint.blueprint_skills
  end # detail
end
