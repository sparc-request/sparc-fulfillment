class AddTotalCostToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :total_cost, :integer
  end
end
