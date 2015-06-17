class Sparc::Procedure < ActiveRecord::Base
  include SparcShard

  belongs_to :appointment
  belongs_to :line_item
  belongs_to :service
  belongs_to :visit
end
