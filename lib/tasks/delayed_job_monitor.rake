require 'open3'
require 'slack-notifier'
require 'dotenv/tasks'

task delayed_job_monitor: :environment do
  # https://hooks.slack.com/services/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
  delayed_job_webhook = ENV.fetch("DELAYED_JOB_WEBHOOK", nil)

  if delayed_job_webhook.present?
    notifier = Slack::Notifier.new(delayed_job_webhook)
  end

  stdout, stderr, status = Open3.capture3("RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job status")
  prev_status = stderr

  if stderr =~ /delayed_job: no instances running/
    message = ""
    if delayed_job_webhook.present?
      message += "```[SPARCFulfillment][#{Rails.env}]\n"
      message += prev_status.split("\n").last + "\n" # makes sure we only get the last message and not the warnings, this may go away on production

      message += "delayed_job: attempting restart\n"
    end

    stdout, stderr, status = Open3.capture3("RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job start")
    curr_status = stdout

    if delayed_job_webhook.present?
      message += curr_status + "```"
      notifier.ping(message)
    end
  end
end
