class NotificationDispatcher

  DIRECTLY_IMPORTABLE_CLASSES   = %w(Protocol).freeze
  INDIRECTLY_IMPORTABLE_CLASSES = %w(SubServiceRequest ProjectRole Service).freeze

  def initialize(notification)
    @notification               = notification
    @notification_object_class  = @notification.kind.classify
  end

  def dispatch
    if object_directly_importable?
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
      ProtocolImporterJob.enqueue(@notification.sparc_id, @notification.callback_url, @notification.action)
    when 'ProjectRole'
      UserRoleImporterJob.enqueue(@notification.sparc_id, @notification.callback_url, @notification.action)
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
end
