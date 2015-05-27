FactoryGirl.define do

  factory :document do
  	documentable_id nil
  	documentable_type nil
	doc { fixture_file_upload Rails.root.join('spec', 'support', 'text_document.txt'), 'text/plain' } #beware mass creation may not close files
  end
end
