require 'rails_helper'

RSpec.describe AppointmentCalendarController do
  before :each do
    @user = create(:user)
    sign_in @user
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
      expect(procedure.notes.pluck(:comment)).to include "Set to completed"
    end
  end

  describe "POST create_incomplete_procedure" do
    it "should update the attributes of the procedure" do
      procedure = create(:procedure, appointment: @protocol.participants.first.appointments.first)
      post :create_incomplete_procedure, {
        procedure_id: procedure.id,
        reasons_selectpicker: 'that reason',
        user_id: @user.id,
        user_name: @user.full_name,
        comment: "commented",
        format: :js
      }
      expect(assigns(:procedure).status).to eq('incomplete')
      expect(assigns(:procedure).reason).to eq('that reason')
    end

    it "should create a new note" do
      procedure = create(:procedure, appointment: @protocol.participants.first.appointments.first)
      expect{
        post :create_incomplete_procedure, {
          procedure_id: procedure.id,
          reasons_selectpicker: 'that reason',
          user_id: @user.id,
          user_name: @user.full_name,
          comment: "commented",
          format: :js
        }
      }.to change(Note, :count).by(1)
    end
  end
end
