class Sparc::Visit < ActiveRecord::Base
  
  include SparcShard

  belongs_to :line_items_visit
  belongs_to :visit_group 
end
