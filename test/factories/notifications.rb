FactoryGirl.define do

  factory :notification do
    sparc_id 1
    action 'create'
    callback_url 'http://localhost:5000/protocols/1.json'
  end
end
