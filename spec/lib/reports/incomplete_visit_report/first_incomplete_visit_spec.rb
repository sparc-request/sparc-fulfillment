require 'rails_helper'

RSpec.describe IncompleteVisitReport do

  describe '.first_incomplete_visit' do

    let!(:appointment_first)  { create :appointment_without_validations }
    let!(:appointment_last)   { create :appointment_without_validations }
    let!(:report)             { IncompleteVisitReport.new }

    before { appointment_first.update_attribute :created_at, 1.minute.ago }

    it 'should return the first incomplete Visit' do
      expect(report.first_incomplete_visit).to eq(appointment_first)
    end
  end
end
