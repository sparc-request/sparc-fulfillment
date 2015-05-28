class HumanSubjectsInfo < ActiveRecord::Base

  self.table_name = 'human_subjects_info'

  include SparcShard

  belongs_to :protocol, primary_key: :sparc_id

  def irb_number
    pro_number || hr_number
  end
end
