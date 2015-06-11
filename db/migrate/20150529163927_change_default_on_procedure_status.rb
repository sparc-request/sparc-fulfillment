class ChangeDefaultOnProcedureStatus < ActiveRecord::Migration
  def change
    change_column_default :procedures, :status, "unstarted"
    procedures = []
    procedures << Procedure.where(status: "")
    procedures << Procedure.where(status: nil)
    procedures.flatten.each{|procedure| procedure.update_attributes(status: "unstarted")}
  end
end
