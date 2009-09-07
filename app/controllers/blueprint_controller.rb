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

  def search
    @term = params[:search_term]

    @blueprints = Blueprint.find(:all, 
     :conditions => ['blueprint_name LIKE ?', "%#{params[:search_term]}%"], 
     :order => 'blueprints.tech_level ASC, blueprints.blueprint_name ASC'
    ) # end find

    @inventory = BlueprintInventory.find(:all, :joins => :blueprint,
     :conditions => ['blueprint_name LIKE ?', "%#{params[:search_term]}%"], 
     :order => 'blueprints.tech_level ASC, blueprints.blueprint_name ASC'
    ) # end find
  end
end
