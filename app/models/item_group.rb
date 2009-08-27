class ItemGroup < ActiveRecord::Base
  has_many :blueprints
  has_many :blueprint_materials
end
