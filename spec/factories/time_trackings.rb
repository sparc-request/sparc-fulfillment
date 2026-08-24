FactoryBot.define do
  factory :time_tracking do
    protocol_id { 1 }
    sub_service_request_id { 1 }
    line_item_id { 1 }
    component_id { 1 }
    identity_id { 1 }
    date { "2026-07-26" }
    started_at { "2026-07-26 19:58:16" }
    ended_at { "2026-07-26 19:58:16" }
    quantity { "9.99" }
    notes { "MyString" }
    text { "MyString" }
    status { "MyString" }
  end
end
