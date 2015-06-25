class Sparc::Procedure < ActiveRecord::Base
  include SparcShard

  belongs_to :appointment
  belongs_to :line_item
  belongs_to :service
  belongs_to :visit

  has_many :audits, -> { where auditable_type: 'Procedure' }, foreign_key: :auditable_id
end
