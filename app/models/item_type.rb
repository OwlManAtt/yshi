class ItemType < ActiveRecord::Base
  belongs_to :item_group
  has_many :corp_orders, :foreign_key => 'item_type_id' 
end
