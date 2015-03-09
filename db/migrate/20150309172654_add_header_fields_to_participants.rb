class AddHeaderFieldsToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :recruitment_source, :string
    add_column :participants, :external_id, :string
    add_column :participants, :middle_initial, :string, limit: 1
  end
end
