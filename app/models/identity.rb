class Identity < ActiveRecord::Base

  include SparcShard

  has_many :project_roles
end
