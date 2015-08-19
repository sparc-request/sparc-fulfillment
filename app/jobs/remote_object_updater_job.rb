class RemoteObjectUpdaterJob < ActiveJob::Base

  queue_as :sparc_api_requests

  before_perform do
    skip_faye_callbacks
  end

  after_perform do
    set_faye_callbacks
  end

  def perform(notification)
    object_class          = normalized_object_class(notification)
    local_object          = object_class.constantize.find_or_create_by(sparc_id: notification.sparc_id)
    remote_object         = RemoteObjectFetcher.fetch(notification.callback_url)
    normalized_attributes = RemoteObjectNormalizer.new(object_class, remote_object[object_class.downcase]).normalize!

    local_object_siblings(local_object).each { |object| object.update_attributes normalized_attributes }
  end

  private

  def local_object_siblings(local_object)
    siblings = [local_object]

    if local_object.is_a? Protocol
      Protocol.where(sub_service_request_id: local_object.sub_service_request_id).each do |protocol|
        siblings.push protocol
      end
    end

    siblings
  end

  def normalized_object_class(notification)
    case notification.kind.classify
    when 'Project'
      'Protocol'
    when 'Study'
      'Protocol'
    else
      notification.kind.classify
    end
  end

  def skip_faye_callbacks
    Protocol.skip_callback    :save, :after, :update_faye
    Participant.skip_callback :save, :after, :update_faye
  end

  def set_faye_callbacks
    Protocol.set_callback    :save, :after, :update_faye
    Participant.set_callback :save, :after, :update_faye
  end
end
