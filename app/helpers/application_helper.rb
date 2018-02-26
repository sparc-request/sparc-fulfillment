# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
  def generate_history_text url
    begin
      h = Rails.application.routes.recognize_path(url)
      case h[:action]
      when 'index'
        ['All', h[:controller].humanize].join(' ')
      when 'show'
        klass = h[:controller].classify.constantize
        klass.title h[:id]
      else
        url
      end
    rescue Exception => e
      #TODO do we want the message in test, this is just breadcrumbs
      unless Rails.env.test?
        puts "#"*20
        puts e.message
        puts "#"*20
      end
      return url
    end
  end

  def format_date date
    if date.present?
      date.strftime('%m/%d/%Y')
    else
      ''
    end
  end

  def format_datetime date
    if date.present?
      date.strftime('%F %H:%M')
    else
      ''
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

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def back_link url
    url.to_s + "?back=true" # handles root url as well (nil)
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

  def logged_in identity
    content_tag(:span, "#{t(:navbar)[:logged_in_msg]} #{current_identity.full_name} (#{current_identity.email})", class: "logged-in-as", "aria-hidden" => "true")
  end

  def notes_button params
    content_tag(:button, class: "btn btn-default #{params[:button_class].nil? ? '' : params[:button_class]} list notes", title: params[:title], label: "Notes List", data: {notable_id: params[:object].id, notable_type: params[:object].class.name}, toggle: "tooltip", animation: 'false') do
      content_tag(:span, '', id: "#{params[:object].class.name.downcase}_#{params[:object].id}_notes", class: "glyphicon glyphicon-list-alt #{params[:span_class].nil? ? "" : params[:span_class]} #{params[:has_notes] ? "blue-notes" : ""}")
    end
  end

  def service_name_display(service)
    content_tag(:span, service.name) + (service.is_available ? "" : content_tag(:span, " (Inactive)", class: 'inactive-service'))
  end
end
