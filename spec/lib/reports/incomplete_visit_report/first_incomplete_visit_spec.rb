require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  describe '.first_incomplete_visit' do

    let!(:appointment_first)  { create :appointment_without_validations }
    let!(:appointment_last)   { create :appointment_without_validations }
    let!(:report)             { IncompleteVisitReport.new }

    before do
      appointment_first.update_attribute :created_at, 1.minute.ago
      create_list :procedure_without_validations, 3,
                                                  appointment: appointment_first,
                                                  status: 'unstarted'
      create_list :procedure_without_validations, 3,
                                                  appointment: appointment_last,
                                                  status: 'unstarted'
    end

    it 'should return the first incomplete Visit' do
      expect(report.first_incomplete_visit).to eq(appointment_first)
    end
  end
end
