desc "Ensure procedure_groups record for each core in each appointment"
task add_procedure_groups: :environment do
  puts "Total procedure_groups before update: #{ProcedureGroup.count}"
  bar = ProgressBar.new(Appointment.count)
  Appointment.find_each do |appointment|
    appointment.cores.each do |core|
      begin
        appointment.find_or_create_procedure_group(core.id)
        bar.increment! rescue nil
      rescue => e
        puts "Core #{core.id} in Appointment #{appointment.id} error: #{e.message}"
        bar.increment! rescue nil
      end
    end
  end
  puts "Total procedure_groups after update: #{ProcedureGroup.count}"
end
