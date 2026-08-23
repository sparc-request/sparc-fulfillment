class TimeTracking < ApplicationRecord
  belongs_to :identity
  belongs_to :protocol
  belongs_to :sub_service_request
  belongs_to :line_item
  belongs_to :component, optional: true
end
