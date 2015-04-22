class Service < ActiveRecord::Base
  
  has_paper_trail
  acts_as_paranoid

  has_many :line_items, dependent: :destroy
  has_many :components, as: :composable

  def self.all_services
    Rails.cache.fetch("cache_all_services", expires_in: 1.hour) do
      Service.all
    end
  end

  def self.all_per_participant_visit_services
    Rails.cache.fetch("cache_all_services", expires_in: 1.hour) do
      Service.where(one_time_fee: 0)
    end
  end

  def self.per_participant_visits
    Service.where(one_time_fee: 0)
  end

  def self.one_time_fees
    Service.where(one_time_fee: 1)
  end
end
