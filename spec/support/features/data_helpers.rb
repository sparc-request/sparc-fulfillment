module Features
  module DataHelpers
    
    def create_populated_protocol_data
      @service = create(:service)
      @protocol = create(:protocol)
      @arm = create(:arm, protocol_id: @protocol.id, visit_count: 1)
      @participant = create(:participant, protocol_id: @protocol.id, arm_id: @arm.id)
      @visit_group = create(:visit_group, arm_id: @arm.id)
      @line_item = create(:line_item, arm_id: @arm.id, service_id: @service.id)
      @visit = create(:visit, line_item_id: @line_item.id, visit_group_id: @visit_group.id)
    end
  end
end