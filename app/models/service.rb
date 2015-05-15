class Service < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  has_many :line_items, dependent: :destroy
  has_many :components, as: :composable

  default_scope { order(name: :asc) }
  scope :per_participant_visits,    -> { where(one_time_fee: 0) }
  scope :one_time_fees,             -> { where(one_time_fee: 1) }

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
end
