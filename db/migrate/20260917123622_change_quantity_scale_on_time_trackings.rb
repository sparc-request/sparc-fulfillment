class ChangeQuantityScaleOnTimeTrackings < ActiveRecord::Migration[7.2]
  def change
    change_column :time_trackings, :quantity, :decimal, precision: 10, scale: 2
  end
end
