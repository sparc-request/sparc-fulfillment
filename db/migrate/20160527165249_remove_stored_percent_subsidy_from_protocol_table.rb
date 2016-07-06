class RemoveStoredPercentSubsidyFromProtocolTable < ActiveRecord::Migration
  def change
    remove_column :protocols, :stored_percent_subsidy
  end
end
