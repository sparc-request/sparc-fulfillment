class NotificationDispatcher

  DIRECTLY_IMPORTABLE_CLASSES = %w(Service Protocol).freeze

  def initialize(notification)
    @notification               = notification
    @notification_object_class  = @notification.kind.classify
  end

  def dispatch
    if object_directly_importable? && !overwrite_detected?
      import_directly
    end
  end

  private

  # Create or Find the local model and hand off to a RemoteObjectUpdaterJob for remote update
  def import_directly
    if @notification.action == 'create'
      object = @notification_object_class.constantize.create({ sparc_id: @notification.sparc_id })
    else
      object = persisted_object
    end

    RemoteObjectUpdaterJob.enqueue(object.id, object.class.to_s, @notification.callback_url)
  end

  # Is the object class of the incoming Notification directly importable?
  def object_directly_importable?
    DIRECTLY_IMPORTABLE_CLASSES.include? @notification_object_class
  end

  # If the object exists, do not create a new one
  def overwrite_detected?
    !!persisted_object && @notification.action == 'create'
  end

  # Memoize object if it exists
  def persisted_object
    @persisted_object ||= @notification_object_class.constantize.where(sparc_id: @notification.sparc_id).first
  end
end
