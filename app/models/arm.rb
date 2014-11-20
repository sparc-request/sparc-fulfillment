class Arm < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :protocol

  has_many :line_items, :dependent => :destroy
  has_many :visit_groups, :dependent => :destroy

end
