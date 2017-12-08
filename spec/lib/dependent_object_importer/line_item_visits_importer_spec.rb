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

RSpec.describe LineItemVisitsImporter do

  it 'should inherit from DependentObjectImporter' do
    line_item                 = double('line_item')
    line_item_visits_importer = LineItemVisitsImporter.new(line_item)

    expect(line_item_visits_importer).to be_a(DependentObjectImporter)
    expect(line_item_visits_importer).to respond_to(:save_and_create_dependents)
  end

  describe '#create_dependents' do

    before do
      arm                             = create(:arm_with_visit_groups, protocol: create(:protocol), visit_count: 5)
      line_item                       = build(:line_item, protocol: arm.protocol, service: create(:service), arm: arm)
      @line_item_visit_group_creator  = LineItemVisitsImporter.new(line_item)

      @line_item_visit_group_creator.save_and_create_dependents
    end

    it 'should persist the LineItem record' do
      expect(@line_item_visit_group_creator.line_item).to be_persisted
    end

    it 'should create and associate VisitGroups' do
      expect(@line_item_visit_group_creator.line_item).to have(5).visits
    end
  end
end
