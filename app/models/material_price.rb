class MaterialPrice < ActiveRecord::Base
  belongs_to :blueprint_materials, :primary_key => 'item_type_id', :foreign_key => 'material_type_id'
  def before_create
    # Only allow one unarchived value at a time.
    MaterialPrice.find(:all,:conditions => {:archived => false, :item_type_id => item_type_id}).each {|row| row.archived = true; row.save! }      
  end # end before_save callback
end
