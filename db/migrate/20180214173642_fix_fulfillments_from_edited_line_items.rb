class FixFulfillmentsFromEditedLineItems < ActiveRecord::Migration[5.0]
  def change
    Fulfillment.includes(:line_item).find_each do |fulfillment|
      if fulfillment.line_item.service_id != fulfillment.service_id
        #correct the data here
      end
    end
  end
end
