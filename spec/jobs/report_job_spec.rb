require 'rails_helper'

RSpec.describe ReportJob, type: :job do

  describe '#perform', delay: true do

    before :each do
      @document = create(:document)

      @job = ReportJob.new

      @job.perform(@document, auditing_report_params)
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

  def auditing_report_params
    {
      title: 'auditing_report',
      start_date: '01-01-2015',
      end_date: '02-01-2015',
      protocol_ids: ''
    }
  end
end
