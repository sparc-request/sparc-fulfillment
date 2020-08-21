class AddPositionToProcedures < ActiveRecord::Migration[5.2]
  def change
    add_column :procedures, :position, :integer

    bar = ProgressBar.new(Appointment.count)

# procedures.group_by{|procedure| procedure.service.organization}.each do |org, org_group|

    Appointment.includes(:procedures).find_each do |appointment|
      appointment.procedures.group_by(&:sparc_core_id).each do |core_id, procedure_group|
        procedure_group.each.with_index(1) do |procedure, index|
          procedure.update_column(:position, index)
        end
      end

      bar.increment!
    end
  end
end
