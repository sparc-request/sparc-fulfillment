require 'rails_helper'

RSpec.describe ProtocolHelper do

  describe "#formatted_status" do
    it "should return the formatted status" do
      protocol = create_and_assign_protocol_to_me
      protocol.sub_service_request.update_attributes(status: "Completed")
      status = t(:sub_service_request)[:statuses][protocol.status.to_sym]
      expect(helper.formatted_status(protocol)).to eq(status)
    end
  end

  describe "#formatted_owner" do
    it "should return the formatted owner" do
      identity = create(:identity)
      protocol = create_and_assign_protocol_to_me
      protocol.sub_service_request.update_attributes(owner_id: identity.id)
      owner = protocol.owner.full_name
      expect(helper.formatted_owner(protocol)).to eq(owner)
    end
  end

  describe "#formatted_requester" do
    it "should return the formatted_requester" do
      identity = create(:identity)
      protocol = create(:protocol_imported_from_sparc)
      service_request = create(:service_request, protocol: protocol)
      protocol.sub_service_request.update_attributes(service_request_id: service_request.id)
      protocol.sub_service_request.service_request.update_attributes(service_requester_id: identity.id)
      requester = protocol.service_requester.full_name
      expect(helper.formatted_requester(protocol)).to eq(requester)
    end
  end

  describe "#formatted_study_schedule_report" do
    it "should return html to render the study-schedule-report icon" do
      protocol = create_and_assign_protocol_to_me
      html_return = formatted_study_schedule_report_return(protocol)
      expect(helper.formatted_study_schedule_report(protocol)).to eq(html_return)
    end
  end

  describe "#formatted_coordinators" do
    it "should return html to render the coordinators" do
      protocol = create_and_assign_protocol_to_me
      html_return = formatted_study_schedule_report_return(protocol)
      expect(helper.formatted_study_schedule_report(protocol)).to eq(html_return)
    end
  end

  describe "#arm_per_participant_line_items_by_core" do
    it "should return the line items of arm" do
      arm = create(:protocol_imported_from_sparc).arms.first
      consolidated = true
      expect(helper.arm_per_participant_line_items_by_core(arm, consolidated)).to eq(arm_per_participant_line_items_by_core_return(arm, consolidated))
    end
  end

  describe "#consolidated_one_time_fee_line_items" do
    it "should return the line items of the protocol" do
      protocol = create(:protocol_imported_from_sparc)
      expect(helper.consolidated_one_time_fee_line_items(protocol)).to eq(consolidated_one_time_fee_line_items_return(protocol))
    end
  end

  def formatted_study_schedule_report_return protocol
    content_tag(:div, '', class: 'btn-group') do
      content_tag(:a, href: 'javascript:void(0)', target: :blank, class: 'btn btn-default dropdown-toggle btn-xs study_schedule_report', id: "study_schedule_report_#{protocol.id.to_s}", title: 'Study Schedule Report', 'data-title' => 'Study Schedule Report', 'data-report_type' => 'study_schedule_report', 'data-documentable_id' => protocol.id, 'data-documentable_type' => 'Protocol', 'aria-expanded' => 'false') do
        content_tag(:span, '', class: "glyphicon glyphicon-equalizer")
      end +
      content_tag(:ul, '', class: 'dropdown-menu document-dropdown-menu menu-study-schedule', role: 'menu', id: "document_menu_study_schedule_report_#{protocol.id.to_s}")
    end
  end

  def formatted_coordinators_return coordinators=Array.new
    html = '-'

    if coordinators.any?
      li = Array.new

      span = raw content_tag(:span, '', class: 'caret')
      button = raw content_tag(:button, raw('Coordinators ' + span), type: 'button', class: 'btn btn-default btn-xs dropdown-toggle', 'data-toggle' => 'dropdown', 'aria-expanded' => 'false')
      coordinators.each do |coordinator|
        li.push raw(content_tag(:li, raw(content_tag(:a, coordinator, href: 'javascript:;'))))
      end
      ul = raw content_tag(:ul, raw(li.join), class: 'dropdown-menu', role: 'menu')

      html = raw content_tag(:div, button + ul, class: 'btn-group')
    end

    html
  end

  def arm_per_participant_line_items_by_core_return arm, consolidated=false
    line_items = arm.line_items
    if consolidated && Sparc::Arm.where(id: arm.sparc_id).any?
      sparc_arm = Sparc::Arm.where(id: arm.sparc_id).first
      line_items += sparc_arm.line_items_visits.select{ |liv| liv.line_item.sub_service_request_id != arm.protocol.sub_service_request_id} # add pppv line items that aren't already in cwf
    end

    line_items.group_by{|li| li.service.organization}
  end

  def consolidated_one_time_fee_line_items_return protocol
    line_items = protocol.one_time_fee_line_items
    if Sparc::Protocol.where(id: protocol.sparc_id).any?
      sparc_protocol = Sparc::Protocol.where(id: protocol.sparc_id).first
      sparc_protocol.service_requests.each do |sr|
        line_items += sr.line_items.one_time_fee.select{ |li| li.sub_service_request_id != protocol.sub_service_request_id } # add otf line items that aren't already in cwf
      end
    end

    line_items
  end
end