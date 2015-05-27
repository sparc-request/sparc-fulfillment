class Organization < ActiveRecord::Base

  include SparcShard

  belongs_to :parent, class_name: "Organization"

  has_many :services
  has_many :sub_service_requests

  def inclusive_descendant_services(scope)
    services.
      send(scope).
      push(descendant_organizations.map { |organization| organization.services.send(scope) }).
      flatten
  end

  def descendant_organizations
    descendants = direct_descendants(id)

    descendants.push descendants.map { |descendant| descendant.direct_descendants(descendant.id) }

    descendants.flatten
  end

  def direct_descendants(id=self.id)
    Organization.where(parent_id: id)
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
end

class Program < Organization
end

class Core < Organization
end

class Provider < Organization
end

class Institution < Organization
end
