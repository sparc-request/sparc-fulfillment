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

class ComponentsController < ApplicationController

  def update
    # currently only used by study level activities line item component dropdown
    line_item = LineItem.find(params[:line_item_id])
    new_component_ids = params[:components] == "" ? [] : params[:components].reject(&:empty?).map(&:to_i)
    old_component_ids = line_item.components.where(selected: true).map(&:id)

    to_select = new_component_ids - old_component_ids
    to_select.each do |id|
      component = Component.find(id)
      component.update_attributes(selected: true)
      comment = "Component: #{component.component} indicated"
      line_item.notes.create(kind: 'log', comment: comment, identity: current_identity)
    end

    to_deselect = old_component_ids - new_component_ids
    to_deselect.each do |id|
      component = Component.find(id)
      component.update_attributes(selected: false)
      comment = "Component: #{component.component} no longer indicated"
      line_item.notes.create(kind: 'log', comment: comment, identity: current_identity)
    end

    flash[:success] = t(:line_item)[:flash_messages][:updated]
  end
end
