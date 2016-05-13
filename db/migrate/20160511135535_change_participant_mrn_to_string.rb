class ChangeParticipantMrnToString < ActiveRecord::Migration
  def up
  	change_column :participants, :mrn, :string
  end

  def down
  	change_column :participants, :mrn, :integer
  end
end
