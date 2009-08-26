class Blueprint < ActiveRecord::Base
  belongs_to :item_group
  has_many :blueprint_skills
  has_many :blueprint_materials
end
