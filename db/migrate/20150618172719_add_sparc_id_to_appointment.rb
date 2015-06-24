class AddSparcIdToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :sparc_id, :integer, :after => :id
    add_index "appointments", ["sparc_id"], name: "index_appointments_on_sparc_id", using: :btree
  end
end
