require 'rails_helper'

RSpec.describe ParticipantCalendarController do
  before :each do
    sign_in
    @protocol = create(:protocol_imported_from_sparc)
    @service = create(:service)
  end

  describe "PUT #complete_procedure" do

    it "sets a selected appointment to status compeleted" do
      procedure = create(:procedure, appointment: @protocol.participants.first.appointments.first)
      xhr :put, :complete_procedure, {
        procedure_id: procedure.id
      }
      procedure = Procedure.find(procedure.id)
      expect(procedure.status).to eq "complete"
      excpect(assigns :note)).to be_a_new(Note)
    end

  end
end
