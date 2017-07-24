require "rails_helper"

RSpec.describe TaskMailer, type: :mailer do
  describe "task_confirmation" do
    let(:identity) { create(:identity, email: 'email@test.com') }
    let(:task) { create(:task) }
    let(:mail)  { TaskMailer.task_confirmation(identity, task) }

    #ensure that the subject is correct
    it 'should render the subject' do
      expect(mail.subject).to eq("(SPARCFulfillment) New Task Assigned")
    end

    #ensure that the receiver is correct
    it 'should be to the identity' do
      expect(mail.to).to eq [identity.email]
    end

    #ensure that the sender is correct
    it 'should render the sender email' do
      expect(mail.from).to eq ["from@example.com"]
    end

    #ensure that the e-mail contains a link to the task
    it 'should contain the task link' do
      task_link_path = "tasks_url(id: @task.id)"
      expect(mail.body).to include('/tasks?id')
    end
  end
end