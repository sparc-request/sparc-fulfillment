class Sparc::Note < ActiveRecord::Base
  include SparcShard
  
  belongs_to :appointment
end
