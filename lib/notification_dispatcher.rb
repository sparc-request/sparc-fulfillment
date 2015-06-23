class NotificationDispatcher

  def initialize(notification)
    @notification = notification
  end

  def dispatch
    case notification_object_class
    when "Service"
      ServiceImporterJob.enqueue(@notification.sparc_id, @notification.callback_url, @notification.action)
    when "SubServiceRequest"
      ProtocolImporterJob.enqueue(@notification.sparc_id, @notification.callback_url, @notification.action)
    else
      import_directly
    end
  end

  private

  def notification_object_class
    @notification_object_class ||= @notification.kind.classify
  end

  def import_directly
    object = normalized_object_class.constantize.find_or_create_by(sparc_id: @notification.sparc_id)

    RemoteObjectUpdaterJob.enqueue(object.id, object.class.to_s, @notification.callback_url)
  end

  def normalized_object_class
    case notification_object_class
    when "Study"
      "Protocol"
    else
      notification_object_class
    end
  end
end
