class Protocol < ActiveRecord::Base
  has_many :arms, :dependent => :destroy
end
