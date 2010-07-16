class BlueprintInventory < ActiveRecord::Base
  belongs_to :blueprint
  has_one :cart_item

  validates_numericality_of :material_efficiency, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :production_efficiency, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :price, :greater_than_or_equal_to => 0
  validate :valid_blueprint_id?

  private
  def valid_blueprint_id?
    unless Blueprint.find(blueprint_id)
      errors.add(:blueprint_id, 'is not a valid blueprint')
    end
  end # valid_blueprint_id
end
