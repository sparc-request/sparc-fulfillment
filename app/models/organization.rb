class Organization < ActiveRecord::Base

  include SparcShard

  belongs_to :parent, class_name: "Organization"

  has_many :services
  has_many :sub_service_requests
  has_many :non_process_ssrs_children,
            -> { where(process_ssrs: false) },
            class_name: "Organization",
            foreign_key: :parent_id

  def inclusive_child_services(scope)
    services.
      send(scope).
      push(all_child_services(scope)).
      flatten.
      sort_by(&:name)
  end

  def all_child_organizations
    [
      non_process_ssrs_children,
      non_process_ssrs_children.map(&:all_child_organizations)
    ].flatten
  end

  def all_child_services(scope)
    all_child_organizations.map { |child| child.services.send(scope) }
  end

  def protocols
    Protocol.
      joins(:sub_service_request).
      where(sub_service_requests: { organization_id: id })
  end

  def find_in_organization_tree(klass_name)
    if self.type == klass_name
      self.name
    elsif parent.present?
      parent.find_in_organization_tree(klass_name)
    else
      '-'
    end
  end
end

class Program < Organization
end

class Core < Organization
end

class Provider < Organization
end

class Institution < Organization
end
