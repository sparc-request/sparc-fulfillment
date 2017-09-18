class TaskMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.task_mailer.task_confirmation.subject
  #
  def task_confirmation(identity, task)
    @identity = identity
    @task = task
    env = ENV.fetch('ENVIRONMENT')
    test_email = ENV.fetch('TESTING_EMAIL')
    mail to: env == 'testing' ? test_email : identity.email, subject: "(SPARCFulfillment) New Task Assigned"
  end
end
