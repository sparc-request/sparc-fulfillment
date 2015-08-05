require 'rails_helper'

RSpec.describe ParticipantHelper do

  describe "#performed_by_dropdown" do
    it "should return html to render the performed-by dropdown" do
      appointment = create_and_assign_appointment_to_me
      procedure = create(:procedure, appointment: appointment)
      html_return = performed_by_dropdown_return(procedure)
      expect(helper.performed_by_dropdown(procedure)).to eq(html_return)
    end
  end

  describe "#appointments_for_select" do
    it "should return the appointments on an arm" do
      appointment = create_and_assign_appointment_to_me
      arm = appointment.arm
      participant = appointment.participant
      expect(helper.appointments_for_select(arm, participant)).to eq([appointment])
    end
  end

  describe "#arms_for_appointments" do
    it "should return the arms of appointments" do
      appointments = []
      arms = []
      3.times do
        appointment = create_and_assign_appointment_to_me
        appointments << appointment
        arms << appointment.arm
      end
      expect(helper.arms_for_appointments(appointments)).to eq(arms)
    end
  end

  describe "#us_states" do
    it "should return the US states" do
      us_states = us_states_return
      expect(helper.us_states).to eq(us_states_return)
    end
  end

  describe "#detailsFormatter" do
    it "should return html to render the details icon" do
      participant = create_and_assign_participant_to_me
      html_return = detailsFormatter_return(participant)
      expect(helper.detailsFormatter(participant)).to eq(html_return)
    end
  end

  describe "#editFormatter" do
    it "should return html to render the edit icon" do
      participant = create_and_assign_participant_to_me
      html_return = editFormatter_return(participant)
      expect(helper.editFormatter(participant)).to eq(html_return)
    end
  end

  describe "#deleteFormatter" do
    it "should return html to render the delete icon" do
      participant = create_and_assign_participant_to_me
      html_return = deleteFormatter_return(participant)
      expect(helper.deleteFormatter(participant)).to eq(html_return)
    end
  end

  describe "#changeArmFormatter" do
    it "should return html to render the change-arm icon" do
      participant = create_and_assign_participant_to_me
      html_return = changeArmFormatter_return(participant)
      expect(helper.changeArmFormatter(participant)).to eq(html_return)
    end
  end

  describe "#calendarFormatter" do
    it "should return html to render the calendar icon" do
      participant = create_and_assign_participant_to_me

      #No appointments
      html_return = calendarFormatter_return(participant)
      expect(helper.calendarFormatter(participant)).to eq(html_return)

      #Appointments
      create(:appointment, name: "Appointment", participant: participant, arm: participant.arm)
      html_return = calendarFormatter_return(participant)
      expect(helper.calendarFormatter(participant)).to eq(html_return)
    end
  end

  describe "#statusFormatter" do
    it "should return html to render the status options" do
      participant = create_and_assign_participant_to_me
      html_return = statusFormatter_return(participant)
      expect(helper.statusFormatter(participant)).to eq(html_return)
    end
  end

  describe "#notes_formatter" do
    it "should return html to render the notes button" do
      participant = create_and_assign_participant_to_me
      html_return = notes_formatter_return(participant)
      expect(helper.notes_formatter(participant)).to eq(html_return)
    end
  end

  describe "#participant_report_formatter" do
    it "should return html to render the participant-report icon" do
      participant = create_and_assign_participant_to_me
      html_return = participant_report_formatter_return(participant)
      expect(helper.participant_report_formatter(participant)).to eq(html_return)
    end
  end

  def performed_by_dropdown_return procedure
    identities = Identity.joins(:clinical_providers).where(clinical_providers: { organization: procedure.protocol.organization })

    if procedure.performer.present?
      options = options_for_select(identities.map { |identity| [identity.full_name, identity.id] })
    else
      options = options_for_select(identities.map { |identity| [identity.full_name, identity.id] }.insert(0, [nil, nil]))
    end

    content_tag(:select, options, class: 'performed-by-dropdown selectpicker', data: { width: '125px' }, 'showIcon' => false, id: "performed-by-#{procedure.id}")
  end

  def us_states_return
    ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming', 'N/A']
  end

  def detailsFormatter_return participant
    [
      "<a class='details participant-details ml10' href='javascript:void(0)' title='Details' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-sunglasses'></i>",
      "</a>"
    ].join ""
  end

  def editFormatter_return participant
    [
      "<a class='edit edit-participant ml10' href='javascript:void(0)' title='Edit' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-edit'></i>",
      "</a>"
    ].join ""
  end

  def deleteFormatter_return participant
    [
      "<a class='remove remove-participant' href='javascript:void(0)' title='Remove' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}' participant_name='#{participant.full_name}'>",
      "<i class='glyphicon glyphicon-remove'></i>",
      "</a>"
    ].join ""
  end

  def changeArmFormatter_return participant
    [
      "<a class='edit change-arm ml10' href='javascript:void(0)' title='Change Arm' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}' arm_id='#{participant.arm_id}'>",
      "<i class='glyphicon glyphicon-random'></i>",
      "</a>"
    ].join ""
  end

  def calendarFormatter_return participant
    if participant.appointments.empty?
      "<i class='glyphicon glyphicon-calendar' title='Assign arm to view participant calendar' style='cursor:default'></i>"
    else
      [
        "<a class='participant-calendar' href='javascript:void(0)' title='Calendar' protocol_id='#{participant.protocol_id}' participant_id='#{participant.id}'>",
        "<i class='glyphicon glyphicon-calendar'></i>",
        "</a>"
      ].join ""
    end
  end

  def statusFormatter_return participant
    select_tag "participant_status_#{participant.id}", options_for_select(Participant::STATUS_OPTIONS, participant.status), include_blank: true, class: "participant_status selectpicker form-control #{dom_id(participant)}", data:{container: "body", id: participant.id}
  end

  def notes_formatter_return participant
    content_tag(:button, class: 'btn btn-primary btn-xs participant_notes list notes', 'data-notable-id' => participant.id, 'data-notable-type' => 'Participant') do
      content_tag(:span, '', class: "glyphicon glyphicon-list-alt")
    end
  end

  def participant_report_formatter_return participant
    content_tag(:div, '', class: 'btn-group') do
      content_tag(:a, class: 'btn btn-default dropdown-toggle btn-xs participant_report', id: "participant_report_#{participant.id.to_s}", href: 'javascript:void(0)', target: :blank, title: 'Participant Report', 'data-documentable_type' => 'Protocol', 'data-documentable_id' => participant.protocol.id, 'data-participant_id' => participant.id, 'data-title' => 'Participant Report', 'data-report_type' => 'participant_report', 'aria-expanded' => 'false') do
        content_tag(:span, '', class: 'glyphicon glyphicon-equalizer')
      end +
      content_tag(:ul, '', class: 'dropdown-menu document-dropdown-menu menu-participant', role: 'menu', id: "document_menu_participant_report_#{participant.id.to_s}")
    end
  end
end
