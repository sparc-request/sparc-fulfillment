require 'rails_helper'

RSpec.describe ReportJob, type: :job do

  describe '#perform', delay: true do

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
      expect(Delayed::Job.where(queue: 'faye').count).to eq(1)
    end
  end

  describe '#rescue_from' do
    let(:document) { create(:document, report_type: 'auditing_report') }

    it 'should update the Report state' do
      expect { ReportJob.perform_now(document, nil) }.to change { document.state }.from('Pending').to('Error')
    end
  end

  def auditing_report_params
    2.times { create(:protocol) }
    {
      title: 'auditing_report',
      start_date: '01-01-2015',
      end_date: '02-01-2015',
      identity_id: create(:identity).id,
      protocol_ids: Protocol.all.map(&:id).map(&:to_s)
    }
  end
end
