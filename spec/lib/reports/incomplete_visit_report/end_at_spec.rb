require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  let!(:appointment_1) { create :appointment_without_validations, start_date: 1.day.ago }
  let!(:appointment_2) { create :appointment_without_validations, start_date: Time.current }

  before do
    create :procedure_without_validations, appointment: appointment_1
    create :procedure_without_validations, appointment: appointment_2
  end

  describe '.end_at' do

    context 'end_date attribute present' do

      let!(:report_params)           { { end_date: 2.days.ago } }
      let!(:incomplete_visit_report) { IncompleteVisitReport.new report_params }

      it 'should return the instance end_date attribute' do
        expect(incomplete_visit_report.end_at).to eq(report_params[:end_date])
      end
    end

    context 'end_date attribute not present' do

      let!(:incomplete_visit_report) { IncompleteVisitReport.new }

      it 'should return the last Appointment start_date' do
        expect(incomplete_visit_report.end_at.to_i).to eq(appointment_2.start_date.to_i)
      end
    end
  end
end
