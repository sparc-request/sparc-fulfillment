require 'rails_helper'

RSpec.describe TasksController do

  before :each do
    @task = create(:task)
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
      put :update, {
        id: @task.id,
        task: attributes_for(:task, participant_name: 'Burt Macklin'),
        format: :js
      }
      @task.reload
      expect(@task.participant_name).to eq 'Burt Macklin'
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
    it "should create a new task" do
      expect{
        post :create, {
          id: @task.id,
          task: attributes_for(:task),
          format: :js
        }
      }.to change(Task, :count).by(1)
    end
  end
end