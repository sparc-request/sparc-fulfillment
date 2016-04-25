require 'rails_helper'

RSpec.describe NotesController, type: :controller do

  login_user

  describe 'GET #index' do

    it 'should assign @notes' do
      procedure = create(:procedure_with_notes)
      params    = {
        note: {
          notable_type: 'Procedure',
          notable_id: procedure.id
        }
      }

      xhr :get, :index, params, format: :js

      expect(assigns(:notes).length).to eq(3)
    end
  end

  describe 'GET #new' do

    it 'should instantiate a new note' do
      params = {
        note: {
          notable_type: 'Procedure',
          notable_id: 1
        }
      }

      xhr :get, :new, params

      expect(assigns(:note)).to be_a_new(Note)
    end
  end

  describe 'POST #create' do

    it 'should create a new note' do
      appointment = create(:appointment, name: 'Foggy Bottoms', arm_id: 1, participant_id: 1)
      procedure = create(:procedure, appointment_id: appointment.id)
      params = {
        note: {
          notable_type: 'Procedure',
          notable_id: procedure.id,
          comment: 'okay'
        },
        format: :js
      }

      expect{ post :create, params }.to change(Note, :count).by(1)
      expect(assigns(:note)).to have_attributes(comment: 'okay')
    end
  end
end
