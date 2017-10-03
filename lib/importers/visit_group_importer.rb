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

class VisitGroupImporter

  def initialize(local_arm, remote_arm, remote_sub_service_request)
    @local_arm              = local_arm
    @remote_arm             = remote_arm
    @remote_sub_service_request = remote_sub_service_request
  end

  def create
    remote_arm_visit_groups_ids = @remote_arm['visit_groups'].map { |visit_group| visit_group.values_at('sparc_id') }.compact.flatten

    remote_visit_groups(remote_arm_visit_groups_ids)['visit_groups'].each do |remote_visit_group|
      normalized_attributes     = RemoteObjectNormalizer.new('VisitGroup', remote_visit_group).normalize!
      local_visit_group         = VisitGroup.create(sparc_id: remote_visit_group['sparc_id'])
      attributes                = normalized_attributes.merge!({ arm: @local_arm })

      local_visit_group.update_attributes attributes

      VisitImporter.new(local_visit_group, remote_visit_group, @remote_sub_service_request).create
    end
  end

  # def update
  # end

  # def destroy
  # end

  private

  def remote_visit_groups(visit_group_ids)
    RemoteObjectFetcher.new('visit_group', visit_group_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end
end
