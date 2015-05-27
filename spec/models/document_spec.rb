require 'rails_helper'

RSpec.describe Document, type: :model do
  it { is_expected.to belong_to(:documentable) }

  describe 'attachment' do
    it 'should attach a document and then return it' do
      @document = Document.new
      @document.doc = File.new(Rails.root.join('spec', 'support', 'text_document.txt'))
      @document.save

      expect(@document.doc_file_name).to eq('text_document.txt')
    end
  end
end
