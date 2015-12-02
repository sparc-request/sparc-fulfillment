require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  describe '.incomplete_appointments' do

    context 'incomplete Appointments present' do

      let!(:participant_1) { create :participant_without_validations }
      let!(:participant_2) { create :participant_without_validations }

      before do
        complete_appointment = create :appointment_without_validations, start_date: Time.current,
                                                                        participant: participant_1
        create_list :procedure_without_validations, 3,
                                                    appointment: complete_appointment,
                                                    status: 'complete'
      end

      context ':end_date present' do

        let!(:past_appointment)   { create :appointment_without_validations,  start_date: 1.day.ago,
                                                                              participant: participant_1 }
        let!(:future_appointment) { create :appointment_without_validations,  start_date: 1.day.from_now,
                                                                              participant: participant_2 }
        let!(:report)             { IncompleteVisitReport.new end_date: Time.current }

        before do
          past_appointment.update_attribute :created_at, 1.minute.ago
          create_list :procedure_without_validations, 3,
                                                      appointment: past_appointment,
                                                      status: 'unstarted'
          create_list :procedure_without_validations, 3,
                                                      appointment: future_appointment,
                                                      status: 'unstarted'
        end

        it 'should return incomplete Appointments younger than :end_date' do
          expect(report.incomplete_appointments).to eq([past_appointment])
        end
      end

      context ':start_date present' do

        let!(:past_appointment)   { create :appointment_without_validations,  start_date: 1.day.ago,
                                                                              participant: participant_1 }
        let!(:future_appointment) { create :appointment_without_validations,  start_date: 1.day.from_now,
                                                                              participant: participant_2 }
        let!(:report)             { IncompleteVisitReport.new start_date: Time.current }

        before do
          past_appointment.update_attribute :created_at, 1.minute.ago
          create_list :procedure_without_validations, 3,
                                                      appointment: past_appointment,
                                                      status: 'unstarted'
          create_list :procedure_without_validations, 3,
                                                      appointment: future_appointment,
                                                      status: 'unstarted'
        end

        it 'should return incomplete Appointments older than :start_date' do
          expect(report.incomplete_appointments).to eq([future_appointment])
        end
      end

      context ':start_date and :end_date not present' do

        let!(:incomplete_appointment) { create :appointment_without_validations,  start_date: Time.current,
                                                                                  participant: participant_2 }
        let!(:report)                 { IncompleteVisitReport.new }

        before { create_list :procedure_without_validations,  3,
                                                              appointment: incomplete_appointment,
                                                              status: 'unstarted' }

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
