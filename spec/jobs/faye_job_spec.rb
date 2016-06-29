require 'rails_helper'

RSpec.describe FayeJob, type: :job do

  describe '#enqueue' do

    it 'should create a active_job' do
      protocol = create(:protocol)
      expect(FayeJob).to have_been_enqueued.with(global_id(protocol)) 
    end
  end

  describe '#perform', enqueue: false do

    context 'Protocol#save' do

      before do
        @protocol = create(:protocol)
      end

      it "should POST to the Faye server on the 'protocols' channel" do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with{ |request| request.body.match(/protocols/) }).to have_been_made.at_least_once
      end

      it "should POST to the Faye server on the 'protocol_id' channel" do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with { |request| request.body.match(/protocol_#{@protocol.id}/) }).to have_been_made.at_least_once
      end
    end

    context 'Particpant#save' do

      before do
        @protocol = create(:protocol)
        create(:participant, protocol: @protocol)
      end

      it "should POST to the Faye server on the 'protocols' channel" do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with{ |request| request.body.match(/protocols/) }).to have_been_made.at_least_once
      end

      it "should POST to the Faye server on the 'protocol_id' channel" do
        expect(a_request(:post, /#{ENV['CWF_FAYE_HOST']}/).with { |request| request.body.match(/protocol_#{@protocol.id}/) }).to have_been_made.at_least_once
      end
    end
  end
end
