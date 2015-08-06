class UpdateLabAndBiorepositoryProcedures < ActiveRecord::Migration
  def change
    lab_and_bio_procedures = Procedure.where(sparc_core_name: "Research Laboratory and Biorepository")
    lab_service_names      = Service.where(organization_id: 16).map(&:name)
    bio_service_names      = Service.where(organization_id: 133).map(&:name)

    lab_and_bio_procedures.each do |procedure|
      if lab_service_names.include?(procedure.service_name)
        procedure.update_attributes(sparc_core_name: "Research Laboratory", sparc_core_id: 16)
      elsif bio_service_names.include?(procedure.service_name)
        procedure.update_attributes(sparc_core_name: "Biorepository", sparc_core_id: 133)
      end
    end
  end
end
