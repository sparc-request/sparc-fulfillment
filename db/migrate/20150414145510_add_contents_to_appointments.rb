class AddContentsToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :contents, :string
  end
end
