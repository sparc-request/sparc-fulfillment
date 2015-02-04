class Service < ActiveRecord::Base
  acts_as_paranoid

  has_many :line_items, dependent: :destroy

  def self.all_services
    Rails.cache.fetch("cache_all_services", expires_in: 1.hour) do
      Service.all
    end
  end
end
