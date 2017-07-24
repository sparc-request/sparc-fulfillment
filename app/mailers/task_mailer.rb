class TaskMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.task_mailer.task_confirmation.subject
  #
  def task_confirmation(identity, task)
    @identity = identity
    @task = task
    mail to: identity.email, subject: "(SPARCFulfillment) New Task Assigned"
  end
end
