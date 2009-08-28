class Blueprint < ActiveRecord::Base
  has_many :blueprint_inventories
  belongs_to :item_group
  has_many :blueprint_skills
  has_many :blueprint_materials

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
