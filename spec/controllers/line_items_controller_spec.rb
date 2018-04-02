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

RSpec.describe LineItemsController do

  before :each do
    sign_in
    @protocol = create(:protocol)
    @service = create(:service_with_one_time_fee)
    @service_2 = create(:service)
    @line_item = create(:line_item, protocol: @protocol, service: @service)
    @pppv_line_item = create(:line_item, protocol: @protocol, service: create(:service), arm: create(:arm, protocol: @protocol))
  end

  describe "GET #index" do

    context 'content-type: application/json' do

      it 'renders the :index action' do
        get :index, params: { protocol_id: @protocol.id }, format: :json

        expect(response).to be_success
      end

      it 'assigns @protocol and @line_items' do
        get :index, params: { protocol_id: @protocol.id }, format: :json

        expect(assigns(:protocol)).to be
        expect(assigns(:line_items)).to be
      end
    end
  end

  describe "GET #new" do
    it "should instantiate a new LineItem" do
      get :new, params: { protocol_id: @protocol.id }, format: :js, xhr: true
      expect(assigns(:line_item)).to be_a_new(LineItem)
    end
  end

  describe "POST #create" do
    it "should create a new LineItem" do
      expect{
        post :create, params: {
          line_item: attributes_for(:line_item, protocol_id: @protocol.id, service_id: @service.id)
        }, format: :js
      }.to change(LineItem, :count).by(1)
    end
  end

  describe "GET #edit" do
    it "should select an instantiated LineItem" do
      get :edit, params: { id: @line_item.id }, format: :js, xhr: true
      expect(assigns(:line_item)).to eq(@line_item)
    end
  end

  describe "PUT #update" do
    it "should update a otf LineItem and create and associated note" do
      put :update, params: {
        id: @line_item.id,
        line_item: attributes_for(:line_item, protocol_id: @protocol.id, service_id: @service.id, quantity_requested: 328)
      }, format: :js
      @line_item.reload
      expect(@line_item.quantity_requested).to eq 328
      expect(@line_item.notes.map{|n| n.comment}).to include("Quantity Requested changed to 328")
    end

    it "should update a pppv LineItem and update associated procedures" do
      create(:procedure, visit: create(:visit, line_item: @pppv_line_item, visit_group: create(:visit_group, arm: @pppv_line_item.arm)), appointment: create(:appointment, arm: @pppv_line_item.arm, name: "this", participant: create(:participant, protocol: @protocol)))
      put :update, params: {
        id: @pppv_line_item.id,
        line_item: {service_id: @service_2.id}
      }, format: :js
      @pppv_line_item.reload
      expect(@pppv_line_item.service_id).to eq @service_2.id
      expect(@pppv_line_item.visits.map{|v| v.procedures.map{|p| p.service_id}}.flatten.uniq.first).to eq(@service_2.id)
    end
  end

  describe "DELETE #destroy" do
    it "should delete a line item with out fulfillments" do
      delete :destroy, params: { id: @line_item.id }, format: :js
      expect(@line_item.deleted?)
    end

    it "should not delete a line item with fulfilmments" do
      fulfillment = create(:fulfillment, line_item: @line_item)
      delete :destroy, params: { id: @line_item.id }, format: :js
      expect(@line_item).to be
    end
  end
end

