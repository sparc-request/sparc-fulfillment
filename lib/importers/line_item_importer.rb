class LineItemImporter

  def initialize(local_arm, remote_arm)
    @local_arm  = local_arm
    @remote_arm = remote_arm
  end

  def create
    remote_arm_line_items_visits_ids = @remote_arm['line_items_visits'].map { |line_items_visit| line_items_visit.values_at('sparc_id') }.compact.flatten

    remote_line_items_visits(remote_arm_line_items_visits_ids)['line_items_visits'].each do |remote_line_item_visit|
      visit_ids                     = remote_line_item_visit['visits'].map { |visit| visit.values_at('sparc_id') }.flatten
      remote_line_item_callback_url = remote_line_item_visit['line_item']['callback_url']
      remote_line_item              = RemoteObjectFetcher.fetch(remote_line_item_callback_url)

      remote_line_item_service_id   = remote_line_item['line_item']['service_id']
      local_service                 = Service.find(remote_line_item_service_id)
      local_line_item_attributes    = { protocol: @local_arm.protocol, arm: @local_arm, service: local_service }

      local_line_item               = LineItem.create(local_line_item_attributes)

      Visit.where(sparc_id: visit_ids).update_all line_item_id: local_line_item.id
    end
  end

  # def update
  # end

  # def destroy
  # end

  private

  def remote_line_items_visits(line_items_visit_ids)
    RemoteObjectFetcher.new('line_items_visit', line_items_visit_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end
end
