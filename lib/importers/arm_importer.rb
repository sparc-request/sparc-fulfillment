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

class ArmImporter

  def initialize(local_protocol, remote_protocol, remote_sub_service_request)
    @local_protocol             = local_protocol
    @remote_protocol            = remote_protocol
    @remote_sub_service_request = remote_sub_service_request
  end

  def create
    remote_protocol_arms_sparc_ids = @remote_protocol['protocol']['arms'].map { |arm| arm.values_at('sparc_id') }.compact.flatten

    if remote_protocol_arms_sparc_ids.any?

      remote_arms(remote_protocol_arms_sparc_ids)['arms'].each do |remote_arm|
        normalized_attributes         = RemoteObjectNormalizer.new('Arm', remote_arm).normalize!
        local_arm                     = Arm.create(sparc_id: remote_arm['sparc_id'])
        attributes                    = normalized_attributes.merge!({ protocol: @local_protocol })

        local_arm.update_attributes attributes

        LineItemImporter.new(local_arm, local_arm.protocol, @remote_sub_service_request['sub_service_request']).create
        VisitGroupImporter.new(local_arm, remote_arm, @remote_sub_service_request['sub_service_request']).create
      end
    end
  end

  private

  def remote_arms(arm_ids)
    @remote_arms ||= RemoteObjectFetcher.new('arm', arm_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end
end
