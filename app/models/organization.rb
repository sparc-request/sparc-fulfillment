class Organization < ActiveRecord::Base

  include SparcShard

  has_many :services
  has_many :sub_service_requests

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
