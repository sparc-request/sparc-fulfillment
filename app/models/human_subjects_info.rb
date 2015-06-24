class HumanSubjectsInfo < ActiveRecord::Base

  include SparcShard
  
  self.table_name = self.table_name_prefix + 'human_subjects_info'

  belongs_to :protocol, primary_key: :sparc_id

  def irb_number
    pro_number.blank? ? hr_number : pro_number
  end
end
