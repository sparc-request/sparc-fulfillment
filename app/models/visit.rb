class Visit < ActiveRecord::Base
  belongs_to :line_item
  belongs_to :visit_group
end
