# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

class VisitImporter

  def initialize(local_visit_group, remote_visit_group, remote_sub_service_request)
    @local_visit_group      = local_visit_group
    @remote_visit_group     = remote_visit_group
    @remote_sub_service_request = remote_sub_service_request
  end

  def create
    remote_visit_group_visits_ids = @remote_visit_group['visits'].map { |visit| visit.values_at('sparc_id') }.compact.flatten

    remote_visits(remote_visit_group_visits_ids)['visits'].each do |remote_visit|

      remote_line_items_visit_sparc_id = remote_visit['line_items_visit']['sparc_id']
      remote_line_items_visit = remote_line_items_visits(remote_line_items_visit_sparc_id)['line_items_visit']
      remote_line_item_callback_url    = remote_line_items_visit['line_item']['callback_url']
      remote_line_item = RemoteObjectFetcher.fetch(remote_line_item_callback_url)['line_item']
      local_line_item = LineItem.find_by_sparc_id remote_line_item['sparc_id']

      next unless remote_line_item['sub_service_request_id'] == @remote_sub_service_request['sparc_id']

      normalized_attributes   = RemoteObjectNormalizer.new('Visit', remote_visit).normalize!
      local_visit             = Visit.create(sparc_id: remote_visit['sparc_id'])
      visit_attributes        = normalized_attributes.merge!({ visit_group: @local_visit_group, line_item: local_line_item })

      local_visit.update_attributes visit_attributes
    end
  end

  # def update
  # end

  # def destroy
  # end

  private

  def remote_line_items_visits(id)
    RemoteObjectFetcher.new('line_items_visit', id, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_visits(visit_ids)
    RemoteObjectFetcher.new('visit', visit_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end
end
