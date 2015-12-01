require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  describe '.last_incomplete_visit' do

    let!(:appointment_1) { create :appointment_without_validations, start_date: Time.current }
    let!(:appointment_2) { create :appointment_without_validations, start_date: Time.current }
    let!(:report)        { IncompleteVisitReport.new }

    before do
      create :procedure_without_validations, appointment: appointment_1
      create :procedure_without_validations, appointment: appointment_2
    end

    it 'should return the last incomplete Visit' do
      expect(report.last_incomplete_visit).to eq(appointment_2)
    end
  end
end
