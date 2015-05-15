FactoryGirl.define do

  factory :document do
  	documentable_id nil
  	documentable_type nil
  	doc { fixture_file_upload './app/assets/images/sctr_logo.png', 'image/png' } #beware mass creation may not close files
  end
end
