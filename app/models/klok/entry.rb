# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

class Klok::Entry < ActiveRecord::Base
  include KlokShard

  self.primary_key = 'entry_id'

  belongs_to :klok_person, class_name: 'Klok::Person', foreign_key: :resource_id
  belongs_to :klok_project, class_name: 'Klok::Project', foreign_key: :project_id
  has_one :service, through: :klok_project

  delegate :local_protocol,
           to: :klok_project,
           allow_nil: true

  delegate :local_identity,
           to: :klok_person,
           allow_nil: true

  def start_time_stamp=(value)
    super(DateTime.strptime(value,'%Q'))
  end

  def end_time_stamp=(value)
    super(DateTime.strptime(value,'%Q'))
  end

  def decimal_duration
    minutes = duration/60000.0
    minutes/60.0
  end

  def local_protocol_includes_service service
    local_protocol.organization.inclusive_child_services(:one_time_fee, false).include? service
  end

  #### Error Msgs

  def duplicate
    unless self.enabled?
      self.errors[:base] << 'duplicate entry'
    end
  end

  def klok_project_present
    unless self.klok_project.present?
      self.errors[:base] << 'klok project not present'
    end
  end

  def klok_project_ssr_id
    unless self.klok_project.ssr_id
      self.errors[:base] << 'doesnt have SSR ID'
    end
  end

  def klok_project_ssr_id_regex_error
    unless ( /\d\d\d\d-\d\d\d\d/ === self.klok_project.ssr_id )
      self.errors[:base] << 'improper format - correct format is 1234-0001'
    end
  end

  def local_project_error
    unless self.local_protocol.present?
      self.errors[:base] << 'no local project present'
    end
  end

  def service_id_not_ssr_id
    unless ( /\A\d+\z/ === self.klok_project.code )
      self.errors[:base] << 'must have service id, not ssr id'
    end
  end

  def service_error
    unless self.service.present?
      self.errors[:base] << 'no service present'
    end
  end

  def service_not_available_to_protocol_error
    if self.local_protocol && self.service
      unless self.local_protocol_includes_service(self.service)
        self.errors[:base] << 'service not available to protocol'
      end
    end
  end

  def klok_person_error
    unless self.klok_person.present?
      self.errors[:base] << 'no klok person present'
    end
  end

  def local_identity_error
    unless self.local_identity.present?
      self.errors[:base] << 'no local identity present'
    end
  end

  def error_messages
    duplicate
    klok_project_present
    klok_project_ssr_id
    klok_project_ssr_id_regex_error
    local_project_error
    service_id_not_ssr_id
    service_error
    service_not_available_to_protocol_error
    klok_person_error
    local_identity_error
    return self.errors[:base]
  end

  def is_valid?
    self.enabled? &&
    self.klok_project.present? &&
    self.klok_project.ssr_id &&
    ( /\d\d\d\d-\d\d\d\d/ === self.klok_project.ssr_id ) &&  #### validate we have a valid SSR id (comes from parent project)
    self.local_protocol.present? &&
    ( /\A\d+\z/ === self.klok_project.code ) &&  #### validate we actually have a service id and not a SSR id
    self.service.present? &&
    self.local_protocol_includes_service(self.service) &&
    self.klok_person.present? &&
    self.local_identity.present?
  end
end
