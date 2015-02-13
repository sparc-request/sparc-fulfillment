require 'rails_helper'

RSpec.describe FayeJob, delay: true do

  describe '#enqueue' do

    it 'should create a delayed_job', delay: true do
      create(:protocol)

      expect(Delayed::Job.where(queue: 'faye').count).to eq(1)
    end
  end

  describe '#perform' do

    context 'Protocol#save' do

      before do
        @protocol = create(:protocol)

        work_off
      end

      it "should POST to the Faye server on the 'protocols' channel" do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with{ |request| request.body.match(/protocols/) }).to have_been_made.once
      end

      it "should POST to the Faye server on the 'protocol_id' channel" do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with { |request| request.body.match(/protocol_#{@protocol.id}/) }).to have_been_made.once
      end
    end

    context 'Particpant#save' do

      before do
        @protocol = create(:protocol)

        destroy_all_delayed_jobs

        create(:participant, protocol: @protocol)

        work_off
      end

      it "should POST to the Faye server on the 'protocols' channel" do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with{ |request| request.body.match(/protocols/) }).to have_been_made.once
      end

      it "should POST to the Faye server on the 'protocol_id' channel" do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with { |request| request.body.match(/protocol_#{@protocol.id}/) }).to have_been_made.once
      end
    end
  end
end
