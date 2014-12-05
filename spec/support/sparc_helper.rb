module SparcHelper

  def sparc_sends_notification_post(params=valid_params)
    http_login(ENV['SPARC_API_USERNAME'], ENV['SPARC_API_PASSWORD'])

    post '/v1/notifications.json', params, @env
  end

  private

  def valid_params
    notification = build(:notification)

    {
      notification: {
        sparc_id: notification.sparc_id,
        action: notification.action,
        callback_url: notification.callback_url
      }
    }
  end
end
