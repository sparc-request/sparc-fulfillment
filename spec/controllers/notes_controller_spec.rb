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
