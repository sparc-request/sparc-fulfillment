class AuditingReport < Report

  def generate(document)
    document.update_attributes  content_type: 'text/csv',
                                original_filename: "#{@attributes[:title]}.csv"

    CSV.open(document.path, 'wb') do |csv|
      csv << ['From', format_date(@start_date), 'To', format_date(@end_date)]
      csv << ['']
      csv << ['']
      csv << [
        'Protocol ID',
        'Patient Name',
        'Patient ID',
        'Arm Name',
        'Visit Name',
        'Service Completion Date',
        'Marked as Incomplete Date',
        'Marked with Follow-Up Date',
        'Added?',
        'Nexus Core',
        'Service Name',
        'Completed?',
        'Billing Type (R/T/O)',
        'If not completed,
        reason and comment',
        'Follow-Up date and comment',
        'Cost'
      ]
      if @attributes[:protocol_ids].present?
        protocols = Protocol.where(id: @attributes[:protocol_ids].compact)
      else
        protocols = Identity.find(@attributes[:identity_id]).protocols
      end

      protocols.each do |protocol|
        protocol.procedures.to_a.select { |procedure| procedure.handled_date && (@start_date..@end_date).cover?(procedure.handled_date) }.each do |procedure|
          participant = procedure.appointment.participant

          csv << [
            protocol.sparc_id,
            participant.full_name,
            participant.label,
            procedure.appointment.arm.name,
            procedure.appointment.name,
            format_date(procedure.completed_date),
            format_date(procedure.incompleted_date),
            format_date(procedure.follow_up? ? procedure.handled_date : nil),
            added_formatter(procedure),
            procedure.service.organization.name,
            procedure.service_name,
            complete_formatter(procedure),
            procedure.formatted_billing_type,
            reason_formatter(procedure),
            follow_up_formatter(procedure),
            display_cost(procedure.service_cost)
          ]
        end
      end
    end
  end

  private

  def added_formatter(procedure)
    procedure.visit ? '' : '**Added**'
  end

  def complete_formatter(procedure)
    procedure.complete? ? 'Yes' : 'No'
  end

  def reason_formatter(procedure)
    if procedure.incomplete? && procedure.reason_note
      procedure.reason_note.comment
    end
  end

  def follow_up_formatter(procedure)
    if procedure.follow_up_date
      "Due Date: #{format_date(procedure.follow_up_date)} | Comment: #{procedure.task.body}"
    end
  end
end
