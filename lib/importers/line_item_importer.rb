class LineItemImporter

  def initialize(local_arm, remote_arm, remote_sub_service_request)
    @local_arm  = local_arm
    @remote_arm = remote_arm
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
      local_effective_pricing_map          = local_service.current_effective_pricing_map

      local_line_item_attributes           = { protocol: @local_arm.protocol, arm: @local_arm, service: local_service,
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
