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
