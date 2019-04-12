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

RSpec.describe ReportJob, type: :job do

  describe '#perform' do

    before :each do
      @document = create(:document, report_type: 'auditing_report')

      ReportJob.perform_now(@document, auditing_report_params)
    end

    it 'should create a .csv file in the file system' do
      expect(File.read(@document.path)).to be
    end

    it 'should update the Document :state to: Completed' do
      expect(@document.reload.state).to eq('Completed')
    end

    it 'should enqueue a FayeJob worker' do
      expect(FayeJob).to have_been_enqueued.with(global_id(@document))
    end
  end

  describe '#rescue_from' do
    let(:document) { create(:document, report_type: 'auditing_report') }

    it 'should update the Report state' do
      expect { ReportJob.perform_now(document, nil) }.to change { document.state }.from('Processing').to('Error')
    end
  end

  def auditing_report_params
    2.times { create(:protocol) }
    {
      title: 'auditing_report',
      start_date: '01/01/2015',
      end_date: '02/01/2015',
      identity_id: create(:identity).id,
      protocols: Protocol.all.map(&:id).map(&:to_s)
    }
  end
end
