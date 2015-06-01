class ProjectRole < ActiveRecord::Base
  
  include SparcShard

  belongs_to :identity
  belongs_to :protocol, foreign_key: :sparc_id
end
