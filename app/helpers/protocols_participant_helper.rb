# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module ProtocolsParticipantHelper
  def protocols_participant_label(protocols_participant)
    protocols_participant.full_name.truncate(50)
  end

  def protocols_participant_actions(protocols_participant)
    content_tag :div, class: 'd-flex justify-content-center' do
      if action_name == 'show'
        protocols_participant_details_button(protocols_participant)
      else
        raw([
          protocols_participant_details_button(protocols_participant),
          protocols_participant_delete_button(protocols_participant)
        ].join(''))
      end
    end
  end

  def protocols_participant_arm_dropdown(protocols_participant)
    form_for protocols_participant, url: protocol_participant_path(protocols_participant, protocol_id: protocols_participant.protocol_id), method: :put, remote: true do |f|
      f.select :arm_id, options_from_collection_for_select(protocols_participant.protocol.arms, :id, :name, protocols_participant.try(:arm).try(:id)), { include_blank: protocols_participant.arm.nil? }, class: 'selectpicker', onchange: "Rails.fire(this.form, 'submit')"
    end
  end

  def protocols_participant_associate_check(participant, protocol)
    protocols_participant = protocol.protocols_participants.find_by(participant_id: participant.id) || protocol.protocols_participants.new(participant_id: participant.id)
    associated            = !protocols_participant.new_record?
    disabled              = !protocols_participant.can_be_destroyed?
    url                   = associated ? destroy_protocol_participant_path(protocols_participant, protocol_id: protocol.id) : protocol_participants_path(protocol_id: protocol.id, participant_id: participant.id)
    ajax_method           = associated ? :delete : :post
    klass                 = ['btn btn-sm btn-sq', associated ? 'btn-danger remove-participant' : 'btn-primary add-participant']
    icon_klass            = associated ? 'times' : 'plus'
    tooltip               = disabled ? 'cant_delete' : (associated ? 'remove' : 'add')

    link_to url, method: ajax_method, remote: true, class: klass, title: t("protocols_participants.tooltips.#{tooltip}"), data: { toggle: 'tooltip' } do
      icon('fas', icon_klass)
    end
  end

  def protocols_participant_calendar_button(protocols_participant)
    disabled = protocols_participant.appointments.empty?
    content_tag(:div, class: 'tooltip-wrapper', title: disabled ? t('protocols_participants.tooltips.assign_arm') : '', data: { toggle: 'tooltip', boundary: 'window' }) do
      link_to calendar_protocol_participant_path(protocols_participant, protocol_id: protocols_participant.protocol_id), class: ['btn btn-primary', disabled ? 'disabled' : ''] do
        icon('fas', 'calendar-alt')
      end
    end
  end

  def protocols_participant_delete_button(protocols_participant)
    disabled = !protocols_participant.can_be_destroyed?
    content_tag(:div, class: 'tooltip-wrapper', title: disabled ? t('protocols_participants.tooltips.cant_delete') : t('actions.delete'), data: { toggle: 'tooltip', boundary: 'window' }) do
      link_to destroy_protocol_participant_path(protocols_participant, protocol_id: protocols_participant.protocol_id), method: :delete, remote: true, class: ['btn btn-sq btn-danger remove-participant', disabled ? 'disabled' : ''], data: { confirm_swal: 'true' } do
        icon('fas', 'trash')
      end
    end
  end

  def protocols_participant_details_button(protocols_participant)
    link_to participant_details_path(protocols_participant.participant_id), remote: true, class: 'btn btn-sq btn-info mr-1 participant-details is-this-update', title: t('actions.details'), data: { toggle: 'tooltip' } do
      icon('fas', 'eye')
    end
  end

  def protocols_participant_external_id(protocols_participant, opts={})
    external_id = protocols_participant.external_id.present? ? protocols_participant.external_id : t('constants.na')
    if opts[:readonly]
      external_id
    else
      popover = render('external_id_form.html', protocols_participant: protocols_participant)
      link_to external_id, 'javascript:void(0)', data: { toggle: 'popover', content: popover, html: 'true', placement: 'top', trigger: 'manual' }
    end
  end

  def protocols_participant_status_dropdown(protocols_participant, opts={})
    if opts[:readonly]
      protocols_participant.status.present? ? protocols_participant.status : t('constants.na')
    else
      form_for protocols_participant, url: protocol_participant_path(protocols_participant, protocol_id: protocols_participant.protocol_id), method: :put, remote: true do |f|
        f.select :status, options_for_select(Participant::STATUS_OPTIONS, protocols_participant.status), { include_blank: true }, class: 'selectpicker', onchange: "Rails.fire(this.form, 'submit')"
      end
    end
  end

  def protocols_participant_recruitment_source_dropdown(protocols_participant, opts={})
    if opts[:readonly]
      protocols_participant.recruitment_source.present? ? protocols_participant.recruitment_source : t('constants.na')
    else
      form_for protocols_participant, url: protocol_participant_path(protocols_participant, protocol_id: protocols_participant.protocol_id), method: :put, remote: true do |f|
        f.select :recruitment_source, options_for_select(Participant::RECRUITMENT_OPTIONS, protocols_participant.recruitment_source), { include_blank: true }, class: 'selectpicker', onchange: "Rails.fire(this.form, 'submit')"
      end
    end
  end

  def protocols_participant_calendar_arm_options(protocols_participant)
    arms = protocols_participant.arms.map do |arm|
      if arm == protocols_participant.arm
        ["#{ProtocolsParticipant.human_attribute_name(:arm)}: #{arm.name}", arm.id]
      else
        ["#{Arm.model_name.human}: #{arm.name}", arm.id]
      end
    end
    options_for_select(arms, protocols_participant.arm.id)
  end
end
