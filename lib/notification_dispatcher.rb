class NotificationDispatcher

  def initialize(notification)
    @notification = notification
  end

  def dispatch
    case notification_object_class
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
    object = notification_object_class.constantize.find_or_create_by(sparc_id: @notification.sparc_id)

    RemoteObjectUpdaterJob.enqueue(object.id, object.class.to_s, @notification.callback_url)
  end
end
