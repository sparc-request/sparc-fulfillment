require 'rails_helper'

RSpec.describe DocumentsController do

  before :each do
    sign_in
    @line_item = create(:line_item, protocol: create(:protocol), service: create(:service))
    @document = create(:document, documentable_id: @line_item.id, documentable_type: 'LineItem')
  end

  describe "GET #index" do
    it "should get documents" do
      xhr :get, :index, {
        document: {
          documentable_id: @line_item.id,
          documentable_type: 'LineItem'
        },
        format: :js
      }
      expect(assigns(:documents)).to eq([@document])
    end
  end

  describe "GET #new" do
    it "should instantiate a new document" do
      xhr :get, :new, {
        document: {
          documentable_id: @line_item.id,
          documentable_type: 'LineItem'
        },
        format: :js
      }
      expect(assigns(:document)).to be_a_new(Document)
    end
  end

  describe "POST #create" do
    it "should save a new document if valid" do
      file = ActionDispatch::Http::UploadedFile.new({
              :filename => 'text_document.txt',
              :content_type => 'text/plain',
              :tempfile => File.new(Rails.root.join('spec', 'support', 'text_document.txt'))
            })
      expect{
        post :create, {
          document: {
            documentable_id: @line_item.id,
            documentable_type: 'LineItem',
            document: file
          },
          format: :js
        }
      }.to change(Document, :count).by(1)
    end

    it "should not save a new document if invalid" do
      expect{
        post :create, {
          document: {
            documentable_id: @line_item.id,
            documentable_type: 'LineItem',
            document: ""
          },
          format: :js
        }
      }.not_to change(Document, :count)
    end
  end
end
