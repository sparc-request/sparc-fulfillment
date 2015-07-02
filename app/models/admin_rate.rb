class AdminRate < ActiveRecord::Base

  include SparcShard

  belongs_to :line_item
end
