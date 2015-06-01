class Organization < ActiveRecord::Base

  include SparcShard

  belongs_to :parent, class_name: "Organization"

  has_many :services
  has_many :sub_service_requests
  has_many :children, class_name: "Organization",
                      foreign_key: :parent_id

  def inclusive_child_services(scope)
    services.
      send(scope).
      push(all_child_services(scope)).
      flatten.
      sort_by(&:name)
  end

  def protocols
    if sub_service_requests.any?
      sub_service_requests.
        map(&:protocol).
        compact.
        flatten
    else
      Array.new
    end
  end

  def all_child_organizations
    [children, children.map(&:all_child_organizations)].flatten
  end

  def all_child_services(scope)
    all_child_organizations.map { |child| child.services.send(scope) }
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
