# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
