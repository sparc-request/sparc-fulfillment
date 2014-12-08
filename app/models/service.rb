class Service < ActiveRecord::Base
  acts_as_paranoid

  has_many :line_items, dependent: :destroy
end
