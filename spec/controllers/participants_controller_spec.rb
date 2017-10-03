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

RSpec.describe ParticipantsController do

  before :each do
    sign_in
    @protocol = create(:protocol)
    @arm = create(:arm, protocol_id: @protocol.id)
    @participant = create(:participant, protocol_id: @protocol.id)
  end

  describe "GET #index" do
    it "should get participants" do
      get :index, {
        protocol_id: @protocol.id,
        format: :json
      }
      expect(assigns(:participants)).to eq([@participant])
    end
  end

  describe "GET #new" do
    it "should instantiate a new participant" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        format: :js
      }
      expect(assigns(:participant)).to be_a_new(Participant)
    end
  end

  describe "POST #create" do
    it "should create a new participant" do
      attributes = @participant.attributes
      bad_attributes = ["date_of_birth","id", "deleted_at", "created_at", "updated_at", "total_cost"]
      attributes.delete_if {|key| bad_attributes.include?(key)}
      attributes[:date_of_birth] = "09/10/2015"
      expect{
        post :create, {
          participant: attributes,
          format: :js
        }
      }.to change(Participant, :count).by(1)
    end

    it "should assign the arm if there is only one arm on a protocol" do
      attributes = @participant.attributes
      bad_attributes = ["date_of_birth","id", "deleted_at", "created_at", "updated_at", "total_cost"]
      attributes.delete_if {|key| bad_attributes.include?(key)}
      attributes[:date_of_birth] = "09/10/2015"

      xhr :post, :create, {
        protocol_id: @protocol.id,
        participant: attributes,
        format: :js
      }

      expect(assigns(:participant).arm).to eq(@arm)
    end

    it "should not assign the arm if there are multiple arms on a protocol" do
      attributes = @participant.attributes
      bad_attributes = ["date_of_birth","id", "deleted_at", "created_at", "updated_at", "total_cost"]
      attributes.delete_if {|key| bad_attributes.include?(key)}
      attributes[:date_of_birth] = "09/10/2015"

      create(:arm, protocol_id: @protocol.id)
      
      xhr :post, :create, {
        protocol_id: @protocol.id,
        participant: attributes,
        format: :js
      }

      expect(assigns(:participant).arm.nil?).to eq(true)
    end
  end

  describe "GET #edit" do
    it "should select an instantiated participant" do
      xhr :get, :edit, {
        protocol_id: @protocol.id,
        id: @participant.id,
        format: :js
      }
      expect(assigns(:participant)).to eq(@participant)
    end
  end

  describe "PUT #update" do
    it "should update a participant" do
      put :update, {
        protocol_id: @protocol.id,
        id: @participant.id,
        participant: attributes_for(:participant, first_name: 'Chick'),
        format: :js
      }
      @participant.reload
      expect(@participant.first_name).to eq 'Chick'
    end
  end

  describe "DELETE #destroy" do
    it "should delete a participant" do
      expect{
        delete :destroy, {
          protocol_id: @protocol.id,
          id: @participant.id,
          format: :js
        }
      }.to change(Participant, :count).by(-1)
    end
  end

  describe "GET #edit_arm" do
    it "should find the participant" do
      xhr :get, :edit_arm, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        format: :js
      }
      expect(assigns(:participant)).to eq(@participant)
    end
  end

  describe "PUT #update_arm" do
    it "should change a participant's arm" do
      @arm = create(:arm, protocol_id: @protocol.id)
      put :update_arm, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        participant: {arm_id: @arm.id},
        format: :js
      }
      @participant.reload
      expect(@participant.arm_id).to eq @arm.id
    end
  end

  describe "GET #details" do
    it "should select an instantiated participant" do
      xhr :get, :details, {
        protocol_id: @protocol.id,
        participant_id: @participant.id,
        format: :js
      }
      expect(assigns(:participant)).to eq(@participant)
    end
  end
end
