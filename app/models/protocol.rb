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

class Protocol < ApplicationRecord

  include LocalDb

  attr_accessor :document_counter_updated

  has_paper_trail
  acts_as_paranoid

  belongs_to :sub_service_request
  has_one  :subsidy, through: :sub_service_request

  belongs_to :sparc_protocol, class_name: 'Sparc::Protocol', foreign_key: :sparc_id

  has_one :organization, through: :sub_service_request
  has_one :human_subjects_info, primary_key: :sparc_id
  has_many :subsidies, through: :sub_service_requests

  has_many :sub_service_requests, through: :service_requests
  has_many :project_roles,    primary_key: :sparc_id
  has_many :service_requests, primary_key: :sparc_id
  has_many :arms,             dependent: :destroy
  has_many :line_items,       dependent: :destroy
  has_many :fulfillments,     through: :line_items
  has_many :participants,     dependent: :destroy
  has_many :appointments,     through: :participants
  has_many :procedures,       through: :appointments
  has_many :documents,        as: :documentable
  has_many :clinical_providers, through: :organization
  has_many :super_users, through: :organization

  before_save :set_documents_count

  after_save :update_faye
  after_destroy :update_faye

  delegate  :irb_approval_date,
            :irb_expiration_date,
            :irb_number,
            to: :human_subjects_info,
            allow_nil: true

  delegate  :status,
            :owner,
            :service_requester,
            to: :sub_service_request

  delegate :short_title,
           :title,
           :funding_source,
           :potential_funding_source,
           to: :sparc_protocol

  delegate :subsidy_committed,
           :percent_subsidy,
           :total_at_approval,
           to: :subsidy,
           allow_nil: true

  def self.title id
    ["Protocol", Protocol.find(id).srid].join(' ')
  end

  def sparc_uri
    [
      ENV.fetch('GLOBAL_SCHEME'),
      '://',
      ENV.fetch('SPARC_API_HOST'),
      '/dashboard/sub_service_requests/',
      sub_service_request_id
    ].join
  end

  def srid # this is a combination of sparc_id and sub_service_request.ssr_id
    "#{sparc_id} - #{sub_service_request.ssr_id}"
  end

  #TODO:Placeholder for subsidy expended. To be completed when participant calendars are built out.
  def subsidy_expended
    "$0.00"
  end

  def pi
    project_roles.where(role: "primary-pi").first.identity
  end

  def coordinators
    project_roles.where(role: "research-assistant-coordinator").map(&:identity)
  end

  def short_title_with_sparc_id
    "(#{self.srid}) #{self.short_title}"
  end

  def one_time_fee_line_items
    line_items.includes(:service).where(:services => {:one_time_fee => true})
  end

  def protocol_type
    sparc_protocol.type
  end

  def sparc_funding_source
    funding_source.blank? ? potential_funding_source : funding_source
  end

  def billing_business_managers
    project_roles.where(role: "business-grants-manager").map(&:identity)
  end

  def research_master_id
    sparc_protocol.research_master_id
  end

  ##### PRIVATE METHODS #####
  private

  def update_faye
    FayeJob.perform_later(self) unless self.document_counter_updated
  end

  def set_documents_count
    update_attributes(unaccessed_documents_count: 0) if self.unaccessed_documents_count < 0
  end
end
