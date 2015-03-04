class VisitGroupImporter

  def initialize(local_arm, remote_arm)
    @local_arm  = local_arm
    @remote_arm = remote_arm
  end

  def create
    remote_arm_visit_groups_ids = @remote_arm['visit_groups'].map { |visit_group| visit_group.values_at('sparc_id') }.compact.flatten

    remote_visit_groups(remote_arm_visit_groups_ids)['visit_groups'].each do |remote_visit_group|
      normalized_attributes     = RemoteObjectNormalizer.new('VisitGroup', remote_visit_group).normalize!
      local_visit_group         = VisitGroup.create(sparc_id: remote_visit_group['sparc_id'])
      attributes                = normalized_attributes.merge!({ arm: @local_arm })

      local_visit_group.update_attributes attributes

      VisitImporter.new(local_visit_group, remote_visit_group).create
    end
  end

  # def update
  # end

  # def destroy
  # end

  private

  def remote_visit_groups(visit_group_ids)
    RemoteObjectFetcher.new('visit_group', visit_group_ids, { depth: 'full_with_shallow_reflections' }).build_and_fetch
  end
end
