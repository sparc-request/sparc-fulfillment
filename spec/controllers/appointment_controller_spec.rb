# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe AppointmentsController do
  before :each do
    @identity = create(:identity)
    sign_in @identity
    @protocol = create(:protocol_imported_from_sparc)
    @service = create(:service)
    @arm = @protocol.arms.first
    @participant = create(:participant, arm: @arm, protocol: @protocol)
    @custom_appointment = create(:custom_appointment, participant: @participant, arm: @arm, name: "Custom Visit", position: 1)
  end

  describe "GET #new" do
    it "should instantiate a new custom appointment" do
      get :new, params: {
        custom_appointment: { participant_id: @participant.id, arm_id: @arm.id },
      }, format: :js, xhr: true
      expect(assigns(:appointment)).to be_a_new(CustomAppointment)
      expect(assigns(:note)).to be_a_new(Note)
    end
  end

  describe "POST #create" do
    it "should create a new custom appointment" do
      attributes = @custom_appointment.attributes
      bad_attributes = ["id", "deleted_at", "created_at", "updated_at"]
      attributes.delete_if {|key| bad_attributes.include?(key)}
      expect{
        post :create, params: {
          custom_appointment: attributes },
          format: :js
      }.to change(CustomAppointment, :count).by(1)
    end
  end

  describe "GET #show" do

    before :each do
      protocol = create(:protocol_imported_from_sparc)
      visit = Visit.first.update_attributes(research_billing_qty: 1)
      @appointment = Appointment.first
    end

    it "should initialize procedures when there aren't any" do
      expect{
        get :show, params: {
          id: @appointment.id },
          format: :js, xhr: true
      }.to change(Procedure, :count).by(1)
      expect(assigns(:appointment)).to eq(@appointment)
    end

    it "renders the #show view" do
      get :show, params: { id: @appointment.id }, format: :js, xhr: true
      expect(response).to render_template :show
    end
  end

  describe "GET #completed_appointments" do
    it 'get only the completed appointments for the participant' do
    end
  end

  describe "PATCH #update" do
    it "should save the start date" do
      tomorrow = Time.now.tomorrow
      appointment = create(:appointment, start_date: Time.now, arm: @arm, name: "Visit 1", participant: @participant)
      patch :update, params: {
        id: appointment.id,
        field: 'start_date',
        appointment: attributes_for(:appointment, start_date: tomorrow.strftime("%F")),
      }, format: :js
      expect(assigns(:appointment).start_date.strftime("%F")).to eq(tomorrow.strftime("%F"))
    end

    it "should save the completed date" do
      tomorrow = Time.now.tomorrow
      appointment = create(:appointment, start_date: Time.current, completed_date: Time.now, arm: @arm, name: "Visit 1", participant: @participant)
      put :update, params: {
        id: appointment.id,
        field: 'completed_date',
        appointment: attributes_for(:appointment, completed_date: tomorrow.strftime("%F"))
      }, format: :js
      expect(assigns(:appointment).completed_date.strftime("%F")).to eq(tomorrow.strftime("%F"))
    end
  end
end
