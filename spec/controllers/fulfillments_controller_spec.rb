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

RSpec.describe FulfillmentsController do

  before :each do
    sign_in
    @line_item = create(:line_item, protocol: create(:protocol_imported_from_sparc), service: create(:service))
    @fulfillment = create(:fulfillment, line_item: @line_item)
  end

  describe "GET #index" do

    context 'content-type: application/json' do

      it 'renders the :index action' do
        get :index, params: { line_item_id: @line_item.id }, format: :js, xhr: true

        expect(response).to be_success
      end

      it 'assigns @line_item' do
        get :index, params: { line_item_id: @line_item.id }, format: :js, xhr: true

        expect(assigns(:line_item)).to be
      end
    end

    context 'content-type: application/js' do

      it 'assigns @fulfillments' do
        get :index, params: { line_item_id: @line_item.id }, format: :json

        expect(assigns(:fulfillments)).to be
      end
    end
  end

  describe "GET #new" do
    it "should instantiate a new Fulfillment" do
      get :new, params: { line_item_id: @line_item.id }, format: :js, xhr: true
      expect(assigns(:fulfillment)).to be_a_new(Fulfillment)
    end
  end

  describe "POST #create" do
    it "should create a new fulfillment" do
      attributes = @fulfillment.attributes
      attributes.delete_if{ |key| ["id", "fulfilled_at", "created_at", "updated_at"].include?(key) }
      attributes[:fulfilled_at] = Date.today.strftime("%m/%d/%Y")
      attributes[:components] = @line_item.components.map{ |c| c.id.to_s }
      expect{
        post :create, params: { fulfillment: attributes }, format: :js
      }.to change(Fulfillment, :count).by(1)
    end
  end

  describe "GET #edit" do
    it "should select an instantiated fulfillment" do
      get :edit, params: { id: @fulfillment.id }, format: :js, xhr: true
      expect(assigns(:fulfillment)).to eq(@fulfillment)
    end
  end

  describe "PUT #update" do
    it "should update a fulfillment" do
      put :update, params: {
        id: @fulfillment.id,
        fulfillment: attributes_for(:fulfillment, line_item_id: @line_item.id, quantity: 328)
      }, format: :js
      @fulfillment.reload
      expect(@fulfillment.quantity).to eq 328
    end
  end

end
