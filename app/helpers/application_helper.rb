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

module ApplicationHelper
  def format_date(date, opts={})
    if date.present?
      if opts[:html]
        content_tag :span do
          raw date.strftime('%m/%d/%Y')
        end
      else
        date.strftime('%m/%d/%Y')
      end
    end
  end

  def format_datetime(datetime, opts={})
    if datetime.present?
      if opts[:html]
        content_tag :span do
          raw datetime.strftime('%m/%d/%Y %l:%M') + content_tag(:span, datetime.strftime(':%S'), class: 'd-none') + datetime.strftime(' %p')
        end
      else
        datetime.strftime('%m/%d/%Y %l:%M:%S %p')
      end
    end
  end

  def format_count(value, digits=1)
    if value >= 10.pow(digits)
      "#{value - (value - (10.pow(digits) - 1))}+"
    else
      value
    end
  end

  def display_cost cost
    dollars = (cost / 100.0) rescue nil
    dollar, cent = dollars.to_s.split('.')
    dollars_formatted = "#{dollar}.#{cent[0..1]}".to_f

    number_to_currency(dollars_formatted, seperator: ",")
  end

  def hidden_class val
    :hidden if val
  end

  def disabled_class val
    :disabled if val
  end

  # Class a div containing a disabled button so that
  # you can attach an onclick listener to the div
  # to alert the user why button is disabled.
  def contains_disabled_class val
    :contains_disabled if val
  end

  def pretty_tag(tag)
    tag.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def body_class
    qualified_controller_name = controller.controller_path.gsub('/','-')

    "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"
  end

  ##Sets css bootstrap classes for rails flash message types##
  def twitterized_type type
    case type.to_sym
      when :alert
        "alert-danger"
      when :error
        "alert-danger"
      when :notice
        "alert-info"
      when :success
        "alert-success"
      else
        type.to_s
    end
  end

  def truncated_formatter data
    [
      "<div data-toggle='tooltip' data-placement='left' data-animation='false' title='#{data}'>",
      "#{data}",
      "</div>"
    ].join ""
  end

  def truncated_formatter_external_id protocols_participants
    external_ids = protocols_participants.map{ |protocols_participant| protocols_participant.external_id}.reject(&:blank?).join(', ')
    [
      "<div data-toggle='tooltip' data-placement='left' data-animation='false' title='#{external_ids}'>",
      "#{external_ids}",
      "</div>"
    ].join ""
  end

  def truncate_string_length(s, max=70, elided = ' ...')
    #truncates string to max # of characters then adds elipsis
    if s.present?
      s.match( /(.{1,#{max}})(?:\s|\z)/ )[1].tap do |res|
        res << elided unless res.length == s.length
      end
    else
      ""
    end
  end

  def service_name_display(service, strong=false)
    element = strong ? :strong : :span
    content_tag(element, service.name) + (service.is_available ? "" : content_tag(element, " (Inactive)", class: 'inactive-service'))
  end
end
