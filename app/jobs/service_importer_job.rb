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

class ServiceImporterJob < ImporterJob

  def perform sparc_id, callback_url, action
    super {
      case action
      when 'create'
        #create
      when 'update'
        update_components(callback_url)
      when 'destroy'
        #destroy
      end
    }
  end

  private

  def update_components(callback_url)
    service = RemoteObjectFetcher.fetch(callback_url)["service"]
    if service["one_time_fee"]
      service_components = service["components"].split(',')
      line_items = LineItem.where(service_id: service["sparc_id"])
      line_items.each do |li|
        li_components = li.components.map(&:component)
        to_destroy = li_components - service_components
        to_destroy.each{ |td| li.components.where(component: td).first.destroy }

        to_add = service_components - li_components
        to_add.each{ |ta| Component.create(component: ta, position: service_components.index(ta), composable_type: "LineItem", composable_id: li.id) }
      end
    end
  end
end
