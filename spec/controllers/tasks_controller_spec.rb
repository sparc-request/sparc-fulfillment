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
      put :update, {
        id: @task.id,
        task: attributes,
        format: :js
      }
      @task.reload
      expect(@task.body).to eq expected_body
    end
  end

  describe "GET #task_reschedule" do

    it "renders the reschedule modal" do
      xhr :get, :task_reschedule, {
      id: @task.id,
      format: :js }

      expect(response).to be_success
    end
  end

  describe "GET #new" do
    it "should instantiate a new task" do
      xhr :get, :new, {
        id: @task.id,
        format: :js
      }
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe "POST #create" do

    it "should create a new task without a note" do
      assignee = create(:identity)
      attributes = attributes_for(:task)
      attributes[:due_at] = "09/09/2009"
      expect{
        post :create, {
          id: @task.id,
          task: attributes.merge!(assignee_id: assignee.id),
          format: :js
        }
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
        post :create, {
          id: @task.id,
          task: attributes.merge!(assignee_id: assignee.id),
          format: :js
        }
      }.to change(Note, :count).by(1)
    end
  end
end
