# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

RSpec.describe ArmsController do

  before :each do
    sign_in
    @protocol = create(:protocol)
    @arm = create(:arm, protocol_id: @protocol.id)
  end

  describe "GET #new" do
    it "should instantiate a new arm" do
      get :new, params: {
        protocol_id: @protocol.id,
      }, format: :js, xhr: true
      expect(assigns(:arm)).to be_a_new(Arm)
    end
  end

  describe "POST #create" do
    it "should save a new arm if valid" do
      expect{
        post :create, params: {
          protocol_id: @protocol.id,
          arm: attributes_for(:arm)
        }, format: :js
      }.to change(Arm, :count).by(1)
    end

    it "should not save a new arm if invalid" do
      expect{
        post :create, params: {
          protocol_id: @protocol.id,
          arm: attributes_for(:arm, subject_count: 'A')
        }, format: :js
      }.not_to change(Arm, :count)
    end
  end

  describe "DELETE #destroy" do
    it "should delete the arm", enqueue: false do
      @new_arm = create(:arm, protocol_id: @protocol.id) #more than one arm
      expect{
        delete :destroy, params: {
          protocol_id: @protocol.id,
          id: @arm.id
        }, format: :js
      }.to change(Arm, :count).by(-1)
    end

    it "should not delete the arm if last arm" do
      expect{
        delete :destroy, params: {
          protocol_id: @protocol.id,
          id: @arm.id
        }, format: :js
      }.not_to change(Arm, :count)
    end

    it "should not delete the arm if last arm" do
      create(:procedure_complete, arm: @arm)
      expect{
        delete :destroy, params: {
          protocol_id: @protocol.id,
          id: @arm.id
        }, format: :js
      }.not_to change(Arm, :count)
    end
  end

  describe "POST #update" do

    it "should update the arm" do
      post :update, params: {
        id: @arm.id,
        arm: @arm.attributes.merge({"name" => "BABOOM~*"})
      }, format: :js
      expect(assigns(:arm)).to have_attributes(name: "BABOOM~*")
    end
  end
end
