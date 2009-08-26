class BlueprintController < ApplicationController
  def index 
    @groups = ItemGroup.find(:all, :order => 'group_name')
  end

  def list
    @group = ItemGroup.find(params[:id])
    @blueprints = @group.blueprints
  end

  def detail
    @blueprint = Blueprint.find(params[:id])
    @group = @blueprint.item_group
    @materials = @blueprint.blueprint_materials
    @skills = @blueprint.blueprint_skills
  end
end
