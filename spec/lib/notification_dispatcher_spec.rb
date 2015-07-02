require "rails_helper"

RSpec.describe NotificationDispatcher, type: :request do

  describe "#dispatch", delay: true do

    context "SubServiceRequest" do

      context "update" do

        before do
          params = { notification: attributes_for(:notification_sub_service_request_update) }

          sparc_sends_notification_post(params)
        end

        it "should create a ProtocolImporterJob delayed job" do
          expect(Delayed::Job.where("handler LIKE '%struct:ProtocolImporterJob%'").one?).to be
        end
      end
    end

    context 'Protocol' do

      context 'update' do

        it 'should enqueue an ActiveJob' do
          expect { create(:notification_protocol_update) }.to enqueue_a(RemoteObjectUpdaterJob)
        end
      end
    end

    context 'Study' do

      context 'update' do

        it 'should enqueue an ActiveJob' do
          expect { create(:notification_protocol_update) }.to enqueue_a(RemoteObjectUpdaterJob)
        end
      end
    end
  end
end
