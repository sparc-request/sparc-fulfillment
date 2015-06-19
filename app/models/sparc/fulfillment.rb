class Sparc::Fulfillment < ActiveRecord::Base
  
  include SparcShard

  belongs_to :line_item
  has_many :audits, -> { where auditable_type: 'Fulfillment' }, foreign_key: :auditable_id
end
