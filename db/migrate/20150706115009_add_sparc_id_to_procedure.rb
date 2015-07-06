class AddSparcIdToProcedure < ActiveRecord::Migration
  def change
    add_column :procedures, :sparc_id, :integer, :after => :id
    add_index "procedures", ["sparc_id"], name: "index_procedures_on_sparc_id", using: :btree
  end
end
