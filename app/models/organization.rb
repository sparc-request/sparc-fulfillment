class Organization < ActiveRecord::Base

  include SparcShard

  has_many :services
end

class Program < Organization
end

class Core < Organization
end

class Provider < Organization
end

class Institution < Organization
end
