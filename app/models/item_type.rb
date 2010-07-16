class ItemType < ActiveRecord::Base
  belongs_to :item_group
  has_many :corp_orders, :foreign_key => 'item_type_id' 
  has_many :blueprint_materials
  belongs_to :blueprint, :foreign_key => 'product_item_id'
end
