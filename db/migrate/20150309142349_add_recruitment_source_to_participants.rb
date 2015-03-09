class AddRecruitmentSourceToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :recruitment_source, :string
  end
end
