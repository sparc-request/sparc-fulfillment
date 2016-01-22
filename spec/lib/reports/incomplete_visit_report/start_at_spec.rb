require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  let!(:appointment_1) { create :appointment_without_validations, start_date: Time.current }
  let!(:appointment_2) { create :appointment_without_validations, start_date: 1.day.from_now }

  before do
    appointment_1.update_attribute :created_at, 1.minute.ago
    create :procedure_without_validations, appointment: appointment_1
    create :procedure_without_validations, appointment: appointment_2
  end

  describe '.start_at' do

    context 'start_date attribute present' do

      let!(:report_params)           { { start_date: 2.days.from_now.strftime('%Y/%m/%d') } }
      let!(:incomplete_visit_report) { IncompleteVisitReport.new report_params }

      it 'should return the instance start_date attribute' do
        expect(incomplete_visit_report.start_at).to eq(Time.parse report_params[:start_date])
      end
    end

    context 'start_date attribute not present' do

      let!(:incomplete_visit_report) { IncompleteVisitReport.new }

      it 'should return the first Appointment start_date' do
        expect(incomplete_visit_report.start_at.to_i).to eq(appointment_1.start_date.to_i)
      end
    end
  end
end
