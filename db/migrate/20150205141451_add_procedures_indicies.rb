class AddProceduresIndicies < ActiveRecord::Migration
  def change
    add_index "procedures", ["appointment_id"], name: "index_procedures_on_appointment_id", using: :btree
    add_index "procedures", ["service_id"], name: "index_procedures_on_service_id", using: :btree
    add_index "procedures", ["visit_id"], name: "index_procedures_on_visit_id", using: :btree
    add_index "procedures", ["completed_date"], name: "index_procedures_on_completed_date", using: :btree
  end
end
