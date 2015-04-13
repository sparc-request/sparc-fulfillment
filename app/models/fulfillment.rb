class Fulfillment < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :line_item
  belongs_to :user
  belongs_to :service_component

end
