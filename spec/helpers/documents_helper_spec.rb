require 'rails_helper'

RSpec.describe DocumentsHelper do
  
  describe "#format_date" do
    it "should return a formatted date" do
      expect(helper.format_date(Date.new(2015, 8, 4))).to eq("08/04/2015")
    end
  end

  describe "#attached_file_formatter" do
    it "should return html to format the attached_file anchor" do
      protocol = create_and_assign_protocol_to_me
      document = create(:document, documentable_id: protocol.id, documentable_type: 'Protocol')
      
      #Completed document
      html_return = attached_file_formatter_return(document)
      expect(helper.attached_file_formatter(document)).to eq(html_return)
      
      #Incompleted document
      document.update_attributes(state: "Incomplete")
      html_return = attached_file_formatter_return(document)
      expect(helper.attached_file_formatter(document)).to eq(html_return)
    end
  end

  describe "#edit_formatter" do
    it "should return html to format the edit anchor" do
      protocol = create_and_assign_protocol_to_me
      document = create(:document, documentable_id: protocol.id, documentable_type: 'Protocol')
      
      html_return = edit_formatter_return(document)
      expect(helper.edit_formatter(document)).to eq(html_return)
    end
  end

  def attached_file_formatter_return document
    if document.completed?
      content_tag(:a, class: 'attached_file', id: "file_#{document.id}", href: document_path(document), target: :blank, title: 'Download File', 'data-id' => document.id) do
        content_tag(:span, '', class: 'glyphicon glyphicon-file')
      end
    else
      content_tag(:span, '', class: 'glyphicon glyphicon-refresh spin', style: 'cursor:auto')
    end
  end

  def edit_formatter_return document
    [
    "<a class='edit edit-document ml10' href='javascript:void(0)' title='Edit' document_id='#{document.id}'>",
    "<i class='glyphicon glyphicon-edit'></i>",
    "</a>"
    ].join("")
  end
end
