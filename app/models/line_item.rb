class LineItem < ActiveRecord::Base
  belongs_to :arm
  belongs_to :service

  has_many :visits, :dependent => :destroy
end
