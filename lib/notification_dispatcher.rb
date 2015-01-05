class NotificationDispatcher

  DIRECTLY_IMPORTABLE_CLASSES   = %w(Service Protocol).freeze
  INDIRECTLY_IMPORTABLE_CLASSES = %w(SubServiceRequest).freeze

  def initialize(notification)
    @notification               = notification
    @notification_object_class  = @notification.kind.classify
  end

  def dispatch
    if object_directly_importable? && !overwrite_detected?
      import_directly
    elsif object_indirectly_importable?
      import_indirectly
    end
  end

  private

  # Fire the UpdaterJob which corresponds to the Notification kind
  def import_indirectly
    case @notification_object_class
    when 'SubServiceRequest'
      if @notification.action == 'create'
        SubServiceRequestCreaterJob.enqueue(@notification.sparc_id, @notification.callback_url)
      elsif @notification.action == 'update'
        # Something
      end
    end
  end

  # Create or Find the local model and hand off to a RemoteObjectUpdaterJob for remote update
  def import_directly
    object = @notification_object_class.constantize.find_or_create_by(sparc_id: @notification.sparc_id)

    RemoteObjectUpdaterJob.enqueue(object.id, object.class.to_s, @notification.callback_url)
  end

  # Is the object class one that needs a custom import procedure?
  def object_indirectly_importable?
    INDIRECTLY_IMPORTABLE_CLASSES.include? @notification_object_class
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
