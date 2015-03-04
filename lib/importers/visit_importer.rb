class VisitImporter

  def initialize(local_visit_group, remote_visit_group)
    @local_visit_group  = local_visit_group
    @remote_visit_group = remote_visit_group
  end

  def create
    remote_visit_group_visits_ids = @remote_visit_group['visits'].map { |visit| visit.values_at('sparc_id') }.compact.flatten

    remote_visits(remote_visit_group_visits_ids)['visits'].each do |remote_visit|
      normalized_attributes   = RemoteObjectNormalizer.new('Visit', remote_visit).normalize!
      local_visit             = Visit.create(sparc_id: remote_visit['sparc_id'])
      visit_attributes        = normalized_attributes.merge!({ visit_group: @local_visit_group })

      local_visit.update_attributes visit_attributes
    end
  end

  # def update
  # end

  # def destroy
  # end

  private

  def remote_visits(visit_ids)
    RemoteObjectFetcher.new('visit', visit_ids).build_and_fetch
  end
end
