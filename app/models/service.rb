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
end
