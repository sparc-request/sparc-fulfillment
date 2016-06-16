class DelayedDestroyJob < ActiveJob::Base
  queue_as :delayed_destroy

  def perform(object)
    object.destroy
  end
end
