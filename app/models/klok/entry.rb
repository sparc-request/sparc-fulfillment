# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

  def rounded_duration
    minutes = duration/60000.0
    (minutes/15.0).ceil * 15.0
  end

  def decimal_duration
    rounded_duration/60.0
  end

  def is_valid?
    self.klok_project.present? &&
    self.klok_project.ssr_id &&
    self.klok_project.ssr_id.match(/\d\d\d\d-\d\d\d\d/) &&
    self.local_protocol.present? &&
    self.service.present? &&
    self.klok_person.present? &&
    self.local_identity.present?
  end
end
