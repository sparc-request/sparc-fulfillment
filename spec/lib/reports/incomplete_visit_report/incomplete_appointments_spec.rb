require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  describe '.incomplete_appointments' do

    let!(:incomplete_visit_report)  { IncompleteVisitReport.new }
    let!(:complete_appointment)     { create :appointment_without_validations }

    before { create_list :procedure_without_validations, 3, appointment: complete_appointment }

    context 'incomplete Appointments present' do

      let!(:incomplete_appointment) { create :appointment_without_validations, start_date: Time.current }

      before { create_list :procedure_without_validations, 3, appointment: incomplete_appointment }

      it 'should return an array of incomplete Appointments' do
        expect(incomplete_visit_report.incomplete_appointments).to eq([incomplete_appointment])
      end
    end

    context 'incomplete Appointments not present' do

      it 'should return an empty array' do
        expect(incomplete_visit_report.incomplete_appointments).to eq([])
      end
    end
  end
end
