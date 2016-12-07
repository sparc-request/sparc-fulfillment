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

class Klok::Project < ActiveRecord::Base
  include KlokShard

  self.primary_key = 'project_id'

  has_many :klok_entries, class_name: 'Klok::Entry', foreign_key: :project_id
  has_many :klok_people, class_name: 'Klok::Person', foreign_key: :resource_id, through: :klok_entries
  belongs_to :parent_project, class_name: 'Klok::Project', foreign_key: :parent_id
  has_many :child_projects, class_name: 'Klok::Project', foreign_key: :parent_id
  belongs_to :service, foreign_key: :code

  def ssr_id
    parent_project.try(:code) || code
  end

  def local_protocol
    sparc_id, ssr_version = ssr_id.split('-')
    Protocol.where(sparc_id: sparc_id).where.not(sub_service_request_id: nil).select{|p| p.sub_service_request.try(:ssr_id) == ssr_version}.first
  end
end
