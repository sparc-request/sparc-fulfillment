require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  describe '.incomplete_appointments' do

    context 'incomplete Appointments present' do

      context ':start_date and :end_date not present' do

        let!(:participant_1)          { create :participant_without_validations }
        let!(:participant_2)          { create :participant_without_validations }
        let!(:complete_appointment)   { create :appointment_without_validations,  start_date: Time.current,
                                                                                  participant: participant_1 }
        let!(:incomplete_appointment) { create :appointment_without_validations,  participant: participant_2 }
        let!(:report)                 { IncompleteVisitReport.new }

        before do
          create_list :procedure_without_validations, 3,
                                                      appointment: complete_appointment,
                                                      status: 'complete'
          create_list :procedure_without_validations, 3,
                                                      appointment: incomplete_appointment,
                                                      status: 'unstarted'
        end

        it 'should return an array of incomplete Appointments' do
          expect(report.incomplete_appointments).to eq([incomplete_appointment])
        end
      end
    end

    context 'incomplete Appointments not present' do

      let!(:report)  { IncompleteVisitReport.new }

      it 'should return an empty array' do
        expect(report.incomplete_appointments).to eq([])
      end
    end
  end
end
