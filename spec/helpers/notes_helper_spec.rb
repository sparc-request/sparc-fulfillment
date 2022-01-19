# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

RSpec.describe ApplicationHelper do
	describe "#notes_button" do
    context "no notes" do
    	notable = Participant.create()
      params = {
        }

      it "should return a white button with blue text" do
        expect(helper.notes_button(notable,params)).to have_selector(".badge-secondary")
      end
    end

    context "has notes" do
      before :each do
        @notable = create(:participant)
        @notable.notes.create(comment:'test')
        @params = {
        }
      end

      it "should return a blue button with white text" do
        expect(helper.notes_button(@notable,@params)).to have_selector(".badge-warning")
      end
    end

    context "model is present" do
      notable = Participant.create()
      params = {model:"string"
        }
      it "should not return the sq button" do
        expect(helper.notes_button(notable,params)).not_to have_selector(".btn-sq")
      end
    end

    context "model is not present" do
      notable = Participant.create()
      params = {
        }
      it "should return a square button" do
        expect(helper.notes_button(notable,params)).to have_selector(".btn-sq")
      end
    end
  end
end