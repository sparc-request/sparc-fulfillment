require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  describe '.formatted_incomplete_appointments' do

    let!(:report)         { IncompleteVisitReport.new }
    let!(:participant)    { create :participant_with_protocol }
    let!(:appointment)    { create :appointment_without_validations,  start_date: 1.day.ago,
                                                                      participant: participant }
    let!(:procedure)      { create :procedure_without_validations,  appointment: appointment,
                                                                    sparc_core_name: 'SPARC Core' }

    it 'should return a hash of selected attributes' do
      expected = [
        [
          participant.protocol_id,
          participant.last_name,
          participant.first_name,
          appointment.name,
          appointment.start_date.strftime('%m/%d/%Y'),
          appointment.procedures.first.sparc_core_name
        ]
      ]
      expect(report.formatted_incomplete_appointments).to eq(expected)
    end
  end
end
