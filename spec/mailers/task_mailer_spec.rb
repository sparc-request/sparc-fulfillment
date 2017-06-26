require "rails_helper"

RSpec.describe TaskMailer, type: :mailer do
  describe "task_confirmation" do
    let(:mail) { TaskMailer.task_confirmation }

    it "renders the headers" do
      expect(mail.subject).to eq("Task confirmation")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
