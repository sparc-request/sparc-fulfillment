class AddWorkingTitleToTimeTrackingProtocols < ActiveRecord::Migration[7.2]
  def change
    add_column :time_tracking_protocols, :working_title, :string
  end
end
