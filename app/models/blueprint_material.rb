class BlueprintMaterial < ActiveRecord::Base
  belongs_to :blueprint
  belongs_to :item_group
end
