require 'rails_helper'

RSpec.describe AppointmentStatusesController, type: :controller do

  before :each do
    sign_in
    @appointment = create(:appointment)
  end

  describe 'POST #change_statuses' do

    it 'should create a new status' do
      expect{
        post :change_statuses, {
          appointment_id: @appointment.id,
          statuses: ['New Status'],
          format: :js
        }
      }.to change(AppointmentStatus, :count).from(0).to(1)
    end

    it 'should destroy a status' do
      create(:appointment_status, appointment_id: @appointment.id, status: 'New Status')
      expect{
        post :change_statuses, {
          appointment_id: @appointment.id,
          statuses: [],
          format: :js
        }
      }.to change(AppointmentStatus, :count).from(1).to(0)
    end
  end
end
