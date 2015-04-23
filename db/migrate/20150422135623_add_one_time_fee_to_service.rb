class AddOneTimeFeeToService < ActiveRecord::Migration
  def change
    add_column :services, :one_time_fee, :boolean
  end
end
