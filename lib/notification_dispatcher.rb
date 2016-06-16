class NotificationDispatcher

  def initialize(notification)
    @notification = notification
  end

  def dispatch
    case notification_object_class
    when "Service"
      ServiceImporterJob.perform_later(@notification.sparc_id, @notification.callback_url, @notification.action)
    when "SubServiceRequest"
      ProtocolImporterJob.perform_later(@notification.sparc_id, @notification.callback_url, @notification.action)
    else
      import_directly
    end
  end

  private

  def notification_object_class
    @notification_object_class ||= @notification.kind.classify
  end

  def import_directly
    RemoteObjectUpdaterJob.perform_later @notification
  end
end
