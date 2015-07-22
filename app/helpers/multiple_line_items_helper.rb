module MultipleLineItemsHelper
  def render_arm_checkboxes(protocol, arm_ids, page_hash)
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
