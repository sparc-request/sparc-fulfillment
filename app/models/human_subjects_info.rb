class HumanSubjectsInfo < ActiveRecord::Base

  self.table_name = 'human_subjects_info'

  include SparcShard

  belongs_to :protocol
end
