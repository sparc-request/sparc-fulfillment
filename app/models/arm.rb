class Arm < ActiveRecord::Base
  belongs_to :protocol

  has_many :line_items, :dependent => :destroy
  has_many :visit_groups, :dependent => :destroy
end
