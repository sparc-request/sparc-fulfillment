# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

class LineItemImporter

  def initialize(local_arm=nil, local_protocol, remote_sub_service_request)
    @local_arm  = local_arm
    @local_protocol = local_protocol
    @remote_sub_service_request = remote_sub_service_request
  end

  def create
    remote_line_item_ids = @remote_sub_service_request['line_items'].map { |line_item| line_item.values_at('sparc_id') }.compact.flatten

    remote_line_items(remote_line_item_ids)['line_items'].each do |remote_line_item|
      remote_line_item_quantity            = remote_line_item['quantity'] || 0
      remote_line_item_units_per_quantity  = remote_line_item['units_per_quantity'] || 1
      remote_line_item_quantity_requested  = remote_line_item_quantity * remote_line_item_units_per_quantity

      remote_line_item_service_id          = remote_line_item['service_id']
      local_service                        = Service.find(remote_line_item_service_id)

      next if @local_arm and local_service.one_time_fee? # skip one_time_fee service
      next if !@local_arm and !local_service.one_time_fee? # skip per patient service

      local_effective_pricing_map          = local_service.current_effective_pricing_map

      local_line_item_attributes           = { protocol: @local_protocol, arm: @local_arm, service: local_service,
                                               quantity_type: local_effective_pricing_map.quantity_type,
                                               quantity_requested: remote_line_item_quantity_requested,
                                               sparc_id: remote_line_item['sparc_id']
                                             }

      local_line_item                      = LineItem.create(local_line_item_attributes)
    end
  end

  # def update
  # end

  # def destroy
  # end

  private

  def remote_line_items(line_item_ids)
    RemoteObjectFetcher.new('line_items', line_item_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end
end
