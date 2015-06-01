class VisitImporter

  def initialize(local_visit_group, remote_visit_group, remote_sub_service_request)
    @local_visit_group      = local_visit_group
    @remote_visit_group     = remote_visit_group
    @remote_sub_service_request = remote_sub_service_request
  end

  def create
    remote_visit_group_visits_ids = @remote_visit_group['visits'].map { |visit| visit.values_at('sparc_id') }.compact.flatten

    remote_visits(remote_visit_group_visits_ids)['visits'].each do |remote_visit|

      remote_line_items_visit_sparc_id = remote_visit['line_items_visit']['sparc_id']
      remote_line_items_visit = remote_line_items_visits(remote_line_items_visit_sparc_id)['line_items_visit']
      remote_line_item_callback_url    = remote_line_items_visit['line_item']['callback_url']
      remote_line_item = RemoteObjectFetcher.fetch(remote_line_item_callback_url)['line_item']
      local_line_item = LineItem.find_by_sparc_id remote_line_item['sparc_id']

      next unless remote_line_item['sub_service_request_id'] == @remote_sub_service_request['sparc_id']

      normalized_attributes   = RemoteObjectNormalizer.new('Visit', remote_visit).normalize!
      local_visit             = Visit.create(sparc_id: remote_visit['sparc_id'])
      visit_attributes        = normalized_attributes.merge!({ visit_group: @local_visit_group, line_item: local_line_item })

      local_visit.update_attributes visit_attributes
    end
  end

  # def update
  # end

  # def destroy
  # end

  private

  def remote_line_items_visits(id)
    RemoteObjectFetcher.new('line_items_visit', id, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_visits(visit_ids)
    RemoteObjectFetcher.new('visit', visit_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end
end
