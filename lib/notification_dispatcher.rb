class NotificationDispatcher

  def initialize(notification)
    @notification = notification
    @object_class = @notification.kind.classify.constantize
  end

  def dispatch
    unless overwrite_detected?

      if @notification.action == 'create'
        object = @object_class.create({ sparc_id: @notification.sparc_id })
      else
        object = persisted_object
      end

      RemoteObjectUpdaterJob.enqueue(object.id, object.class.to_s, @notification.callback_url)
    end
  end

  private

  # If the object exists, do not create a new one
  def overwrite_detected?
    persisted_object && @notification.action == 'create'
  end

  # Memoize object if it exists
  def persisted_object
    @persisted_object ||= @object_class.where(sparc_id: @notification.sparc_id).first
  end
end
