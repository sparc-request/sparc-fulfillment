class RemoveArmIdDataFromOtfLineItems < ActiveRecord::Migration[5.0]
  def change
    LineItem.with_deleted.includes(:service).where(services: {one_time_fee: true}).where.not(arm_id: nil).each do |line_item|
      line_item.arm_id = nil
      line_item.save(validate: false)
    end
  end
end
