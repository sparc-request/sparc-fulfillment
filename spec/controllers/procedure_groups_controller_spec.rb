require 'rails_helper'
include ProcedureGroupsHelper

RSpec.describe ProcedureGroupsController, type: :controller do
  login_user
  before :each do
    @service = create(:service)
    protocol = create(:protocol_imported_from_sparc)
    arm = protocol.arms.first
    participant = create(:participant)
    protocols_participant = create(:protocols_participant, arm: arm, protocol: protocol, participant: participant)
    @appointment = create(:appointment, name: "Visit Test", arm: arm, protocols_participant: protocols_participant)
  end

  let(:procedure_group) { ProcedureGroup.create!(start_time: '10:00', end_time: '12:00', appointment_id: @appointment.id) }

  describe 'PUT #update' do
    context 'with valid attributes' do
      let(:new_attributes) { { start_time: '11:00', end_time: '13:00' } }

      it 'updates the procedure group' do
        put :update, params: { id: procedure_group.id, procedure_group: new_attributes }, format: :js
        procedure_group.reload
        expect(procedure_group.start_time.hour).to eq(11)
        expect(procedure_group.end_time.hour).to eq(13)
      end

      it 'sets a flash message' do
        put :update, params: { id: procedure_group.id, procedure_group: new_attributes }, format: :js
        expect(flash[:success]).to eq(I18n.t('procedure_groups.flash_messages.updated'))
      end
    end
  end
end
