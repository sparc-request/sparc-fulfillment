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
        expect(format_time(procedure_group.start_time)).to eq('11:00 AM')
        expect(format_time(procedure_group.end_time)).to eq('01:00 PM')
      end

      it 'sets a flash message' do
        put :update, params: { id: procedure_group.id, procedure_group: new_attributes }, format: :js
        expect(flash[:success]).to eq(I18n.t('procedure_groups.flash_messages.updated'))
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) { { start_time: 'hello', end_time: 'good bye' } }

      it 'does not update the procedure group' do
        put :update, params: { id: procedure_group.id, procedure_group: invalid_attributes }, format: :js
        procedure_group.reload
        expect(procedure_group.start_time).to be_nil
        expect(procedure_group.end_time).to be_nil
      end
    end
  end
end
