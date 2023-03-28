# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class MoveComponentsToFulfillments < ActiveRecord::Migration[5.2]
  def change
    CSV.open("tmp/moving_components_report.csv", "wb") do |csv|

      csv << ["Skipped Fulfillment ID:", "Line Item ID:", "Existing Fulfillment Components:", "Line Item Components:"]
      bar = ProgressBar.new(LineItem.count)

      LineItem.includes(:components).find_each do |line_item| ##Grab all line items in batches
        if line_item.components.selected.any? ##Only need to do anything if there are selected line item components

          line_item.fulfillments.each do |fulfillment| ##Iterate over fulfillments
            if fulfillment.components.any?
              ##If it already has components, skip it and add it to the report (fulfillment components don't use the "selected" feature)
              csv << [fulfillment.id, line_item.id, fulfillment.components.map(&:component).join(', '), line_item.components.selected.map(&:component).join(', ')]
              bar.increment!
            else
              ##If not, copy the selected line item components over.
              line_item.components.selected.each do |component|
                fulfillment.components.create(position: component.position, component: component.component)
              end

              bar.increment!
            end
          end
        else
          bar.increment!
        end
      end
    end
    Component.where(composable_type: "LineItem").delete_all
  end
end
