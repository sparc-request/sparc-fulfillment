# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe StudyLevelActivitiesHelper do

  describe "#components_for_select" do
    it "should return components options" do
      components = []
      #No components
      val = helper.components_for_select(components)
      expect(val.include? 'value="This Service Has No Components"')

      #Components
      3.times do
        components << create(:component)
      end
      val = helper.components_for_select(components)
      expect(val.include? 'value="1"')
      expect(val.include? 'value="2"')
      expect(val.include? 'value="3"')
    end
  end

  describe "is protocol of type study?" do
    it "should return true" do

      protocol = create(:protocol)
      sparc_protocol = protocol.sparc_protocol
      sparc_protocol.update_attributes(type: 'Study')

      is_study = helper.is_protocol_type_study? (protocol)

      expect(is_study).to eq Sparc::Protocol.where(id: protocol.sparc_id).first.type == 'Study'
    end

    it "should return false" do

      protocol = create(:protocol)
      sparc_protocol = protocol.sparc_protocol
      sparc_protocol.update_attributes(type: 'Project')

      is_study = helper.is_protocol_type_study? (protocol)

      expect(is_study).to eq Sparc::Protocol.where(id: protocol.sparc_id).first.type == 'Study'
    end
  end
end
