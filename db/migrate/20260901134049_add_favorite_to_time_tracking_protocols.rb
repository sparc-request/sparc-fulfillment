class AddFavoriteToTimeTrackingProtocols < ActiveRecord::Migration[7.2]
  def change
    add_column :time_tracking_protocols, :favorite, :boolean, default: false
  end
end
