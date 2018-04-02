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

RSpec.describe ReportsController, type: :controller do

  login_user

  describe "POST #create" do

    context 'format: :js' do

      before :each do
        create(:protocol)
      end

      it 'should respond with: :success' do
        do_post
        expect(response).to be_success
      end

      it 'should create a document' do
        do_post
        expect(assigns(:document)).to be_an_instance_of Document
      end

      it "should not create a document without a title" do
        params = {report_type: "invoice_report", title: ""}
        do_post params
        expect(assigns(:errors).messages[:title]).to be
      end

      it 'should create a ReportJob ActiveJob' do
        expect(ReportJob).to receive(:perform_later).once
        do_post
      end

      def do_post params={report_type: "invoice_report", title: "Invoice Report 1", start_date: "06/01/2016", end_date: "06/02/2016", organizations: [1], protocols: [1], sort_by: 'Protocol ID', sort_order: 'ASC'}
        post :create, params: params, format: :js, xhr: true
      end

    end
  end
end
