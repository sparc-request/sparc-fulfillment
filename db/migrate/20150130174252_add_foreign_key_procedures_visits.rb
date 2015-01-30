class AddForeignKeyProceduresVisits < ActiveRecord::Migration
  def change
    add_column :procedures, :visit_id, :int
  end
end
