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
end