require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  describe '.first_incomplete_visit' do

    let!(:appointment_1) { create :appointment_without_validations, start_date: Time.current }
    let!(:appointment_2) { create :appointment_without_validations, start_date: Time.current }
    let!(:report)        { IncompleteVisitReport.new }

    before do
      create :procedure_without_validations, appointment: appointment_1
      create :procedure_without_validations, appointment: appointment_2
    end

    it 'should return the first incomplete Visit' do
      expect(report.first_incomplete_visit).to eq(appointment_1)
    end
  end
end
