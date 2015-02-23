class SubServiceRequestImporterJob < ImporterJob

  def perform
    super {
      case action
      when 'create'
        #create
      when 'update'
        import_protocol
      when 'destroy'
        #destroy
      end
    }
  end

  private

  def import_protocol
    normalized_attributes = RemoteObjectNormalizer.new('Protocol', remote_protocol['protocol']).normalize!
    local_protocol        = Protocol.create(normalized_attributes.merge!({ sparc_id: remote_protocol['protocol']['sparc_id'] }))

    import_arms(local_protocol)
    update_faye(local_protocol)
  end

  def import_arms(local_protocol)
    remote_protocol_arms_sparc_ids = remote_protocol['protocol']['arms'].map { |arm| arm.values_at('sparc_id') }.compact.flatten

    remote_arms(remote_protocol_arms_sparc_ids)['arms'].each do |remote_arm|
      normalized_attributes = RemoteObjectNormalizer.new('Arm', remote_arm).normalize!
      local_arm             = Arm.create(sparc_id: remote_arm['sparc_id'])
      attributes            = normalized_attributes.merge!({ protocol: local_protocol })

      local_arm.update_attributes attributes

      import_visit_groups(local_arm, remote_arm)
      import_line_items(local_arm, remote_arm)
    end
  end

  def import_visit_groups(local_arm, remote_arm)
    remote_arm_visit_groups_ids = remote_arm['visit_groups'].map { |visit_group| visit_group.values_at('sparc_id') }.compact.flatten

    remote_visit_groups(remote_arm_visit_groups_ids)['visit_groups'].each do |remote_visit_group|
      normalized_attributes         = RemoteObjectNormalizer.new('VisitGroup', remote_visit_group).normalize!
      local_visit_group             = VisitGroup.create(sparc_id: remote_visit_group['sparc_id'])
      attributes                    = normalized_attributes.merge!({ arm: local_arm })

      local_visit_group.update_attributes attributes

      import_visits(local_visit_group, remote_visit_group)
    end
  end

  def import_line_items(local_arm, remote_arm)
    remote_arm_line_items_visits_ids = remote_arm['line_items_visits'].map { |line_items_visit| line_items_visit.values_at('sparc_id') }.compact.flatten

    remote_line_items_visits(remote_arm_line_items_visits_ids)['line_items_visits'].each do |remote_line_item_visit|
      visit_ids                     = remote_line_item_visit['visits'].map { |visit| visit.values_at('sparc_id') }
      remote_line_item_callback_url = remote_line_item_visit['line_item']['callback_url']
      remote_line_item              = RemoteObjectFetcher.fetch(remote_line_item_callback_url)

      remote_line_item_service_id   = remote_line_item['line_item']['service_id']
      local_service                 = Service.where(sparc_id: remote_line_item_service_id).first
      local_line_item_attributes    = { arm: local_arm, service: local_service }

      local_line_item               = LineItem.create(local_line_item_attributes)
      Visit.where(sparc_id: visit_ids).update_all line_item_id: local_line_item.id
    end
  end

  def import_visits(local_visit_group, remote_visit_group)
    remote_visit_group_visits_ids = remote_visit_group['visits'].map { |visit| visit.values_at('sparc_id') }.compact.flatten

    remote_visits(remote_visit_group_visits_ids)['visits'].each do |remote_visit|
      normalized_attributes   = RemoteObjectNormalizer.new('Visit', remote_visit).normalize!
      local_visit             = Visit.create(sparc_id: remote_visit['sparc_id'])
      visit_attributes        = normalized_attributes.merge!({ visit_group: local_visit_group })

      local_visit.update_attributes visit_attributes
    end
  end

  def remote_sub_service_request
    @remote_sub_service_request ||= RemoteObjectFetcher.fetch(callback_url)
  end

  def remote_service_request
    service_request_id = remote_sub_service_request['sub_service_request']['service_request_id']

    @remote_service_request ||= RemoteObjectFetcher.new('service_request', service_request_id, { depth: 'full' }).build_and_fetch
  end

  def remote_protocol
    protocol_id = remote_service_request['service_request']['protocol_id']

    @remote_protocol ||= RemoteObjectFetcher.new('protocol', protocol_id, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_arms(arm_ids)
    @remote_arms ||= RemoteObjectFetcher.new('arm', arm_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_line_items_visits(line_items_visit_ids)
    RemoteObjectFetcher.new('line_items_visit', line_items_visit_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_visit_groups(visit_group_ids)
    RemoteObjectFetcher.new('visit_group', visit_group_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end

  def remote_visits(visit_ids)
    RemoteObjectFetcher.new('visit', visit_ids).build_and_fetch
  end
end
