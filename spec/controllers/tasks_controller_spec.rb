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

RSpec.describe TasksController, type: :controller do

  before :each do
    @task = create(:task, due_at: "09/09/2009")

    sign_in
  end

  describe "GET #index" do

    context 'content-type: text/html' do

      it 'renders the :index action' do
        get :index, format: :html

        expect(response).to be_success
        expect(response).to render_template :index
      end

      it 'does not assign @tasks' do
        get :index, format: :html

        expect(assigns(:tasks)).to_not be
      end
    end

    context 'content-type: application/json' do

      it 'renders the :index action' do
        get :index, format: :json

        expect(response).to be_success
      end

      it 'assigns @tasks' do
        get :index, format: :json

        expect(assigns(:tasks)).to be
      end
    end
  end

  describe "PUT #update" do

    it "should update a task" do
      expected_body = "New body"
      attributes = attributes_for(:task)
      attributes[:due_at] = "09/09/2009"
      attributes[:body] = expected_body
      put :update, params: {
        id: @task.id,
        task: attributes
      }, format: :js
      @task.reload
      expect(@task.body).to eq expected_body
    end
  end

  describe "GET #task_reschedule" do

    it "renders the reschedule modal" do
      get :task_reschedule, params: { id: @task.id }, format: :js, xhr: true

      expect(response).to be_success
    end
  end

  describe "GET #new" do
    it "should instantiate a new task" do
      get :new, params: { id: @task.id }, format: :js, xhr: true
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe "POST #create" do

    it "should create a new task without a note" do
      assignee = create(:identity)
      attributes = attributes_for(:task)
      attributes[:due_at] = "09/09/2009"
      expect{
        post :create, params:{
          id: @task.id,
          task: attributes.merge!(assignee_id: assignee.id)
        }, format: :js
      }.to change(Task, :count).by(1)
    end

    it "should create a task with a note" do
      assignee = create(:identity)
      appointment = create(:appointment, name: 'Sandy Bottoms', arm_id: 1, participant_id: 1)
      procedure = create(:procedure, appointment_id: appointment.id)
      attributes = attributes_for(:task)
      attributes[:due_at] = "09/09/2009"
      attributes[:notes] = {comment: "comment", notable_type: 'Procedure'}
      attributes[:assignable_type] = "Procedure"
      attributes[:assignable_id] = procedure.id
      expect{
        post :create, params: {
          id: @task.id,
          task: attributes.merge!(assignee_id: assignee.id)
        }, format: :js
      }.to change(Note, :count).by(1)
    end
  end
end
