require 'rails_helper'

RSpec.describe MultipleLineItemsHelper do

  describe "#render_arm_checkboxes" do
    it "should return html to render arm checkboxes" do
      protocol = create_and_assign_protocol_to_me
      page_hash = {}
      arm_ids = []

      #Render associated arm checkboxes
      3.times do
        arm = create(:arm, protocol: protocol)
        arm_ids << arm.id
        page_hash[arm.id] = 1
      end
      html_return = render_arm_checkboxes_return(protocol, arm_ids, page_hash)
      expect(helper.render_arm_checkboxes(protocol, arm_ids, page_hash)).to eq(html_return)

      #Render no associated arms message
      arm_ids = [] 
      html_return = render_arm_checkboxes_return(protocol, arm_ids, page_hash)
      expect(helper.render_arm_checkboxes(protocol, arm_ids, page_hash)).to eq(html_return)
    end
  end

  def render_arm_checkboxes_return protocol, arm_ids, page_hash
    html = ""
    protocol.arms.each do |arm|
      html << content_tag(:div, class: "checkbox arm-checkbox", id: "arm_#{arm.id}_checkbox", style: arm_ids.include?(arm.id) ? "" : "display:none;") do
        content_tag(:label) do
          content_tag(:input, type: "checkbox", id: "arm_ids_", name: "arm_ids[]", value: [arm.id, page_hash[arm.id.to_s].to_i]) do
          end +
          "#{arm.name}"
        end
      end
    end
    html << content_tag(:div, "No associated arms were found", class: "no_arms_message", style: "padding-top:7px; display: #{protocol.arms.detect{|arm| arm_ids.include?(arm.id)}.nil? ? '' : 'none;'}")
    raw html 
  end
end