# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

  require 'csv'

  include LocalDb

  attr_accessor :document_counter_updated

  has_paper_trail
  acts_as_paranoid

  belongs_to :sub_service_request
  belongs_to :sparc_protocol,       class_name: 'Sparc::Protocol', foreign_key: :sparc_id

  has_one :human_subjects_info,     primary_key: :sparc_id

  has_one :pi_role,                 -> { where(role: 'primary-pi') }, class_name: "ProjectRole", primary_key: :sparc_id
  has_one :pi,                      through: :pi_role, source: :identity

  has_one :organization,            through: :sub_service_request
  has_one :subsidy,                 through: :sub_service_request

  has_many :arms,                   dependent: :destroy
  has_many :line_items,             dependent: :destroy
  has_many :protocols_participants, dependent: :destroy
  has_many :service_requests,       primary_key: :sparc_id
  has_many :project_roles,          primary_key: :sparc_id
  has_many :documents,              as: :documentable

  has_many :irb_records,            through: :human_subjects_info
  has_many :sub_service_requests,   through: :service_requests
  has_many :subsidies,              through: :sub_service_requests
  has_many :clinical_providers,     through: :organization
  has_many :super_users,            through: :organization
  has_many :participants,           through: :protocols_participants
  has_many :appointments,           through: :protocols_participants
  has_many :procedures,             through: :appointments
  has_many :fulfillments,           through: :line_items

  before_save :set_documents_count

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
           :research_master_id,
           to: :sparc_protocol,
           :allow_nil => true

  delegate :subsidy_committed,
           :percent_subsidy,
           :total_at_approval,
           to: :subsidy,
           allow_nil: true

  scope :search, -> (term) {
    rmid_protocols = Sparc::Protocol.where(Sparc::Protocol.arel_table[:research_master_id].matches("#{term}%"))

    joins(:sub_service_request, :pi).where(Protocol.arel_table[:sparc_id].matches("#{term}%")
    ).or(
      joins(:sub_service_request, :pi).where(id: rmid_protocols)
    ).or(
      joins(:sub_service_request, :pi).where(Sparc::Protocol.arel_table[:short_title].matches("%#{term}%"))
    ).or(
      joins(:sub_service_request, :pi).where(Identity.arel_full_name.matches("%#{term}%"))
    ).or(
      joins(:sub_service_request, :pi).where(SubServiceRequest.arel_table[:org_tree_display].matches("%#{term}%"))
    )
  }

  scope :with_status, -> (status) {
    return if status.blank?
    joins(:sub_service_request).where(sub_service_requests: { status: status })
  }

  scope :sorted, -> (sort, order) {
    sort  = 'id' if sort.blank?
    order = 'desc' if order.blank?

    case sort
    when 'srid'
      order(Protocol.arel_table[:sparc_id].send(order), SubServiceRequest.arel_table[:ssr_id].send(order))
    when 'rmid'
      order(Sparc::Protocol.arel_table[:research_master_id].send(order))
    when 'pi'
      order(Identity.arel_full_name.send(order))
    when 'irb_approval_date'
      order(IrbRecord.arel_table[:irb_approval_date].send(order))
    when 'irb_expiration'
      order(IrbRecord.arel_table[:irb_expiration_date].send(order))
    when 'organizations'
      order(SubServiceRequest.arel_table[:org_tree_display].send(order))
    when 'status'
      order(SubServiceRequest.arel_table[:status].send(order))
    else
      order(sort => order)
    end
  }

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

  def label
    "(#{self.sparc_id}) #{self.short_title}"
  end

  def srid # this is a combination of sparc_id and sub_service_request.ssr_id
    "#{sparc_id} - #{sub_service_request.ssr_id}"
  end

  def coordinators
    if project_roles.loaded?
      project_roles.select{ |pr| pr.role == "research-assistant-coordinator"}.map(&:identity)
    else
      project_roles.where(role: "research-assistant-coordinator").map(&:identity)
    end
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

  # Leaving this method in for now because it's referenced in migrations (and several dozen times within the application, increasing the liklihood that its sudden removal might negatively impact existing Tableau report templates).
  def sparc_funding_source
    # Formerly used to point to either a "potential_funding_source" attribute (now defunct) or a "funding_source" attribute from SPARC Request.
    # funding_source.blank? ? potential_funding_source : funding_source
    funding_source
  end

  def billing_business_managers
    if project_roles.loaded?
      project_roles.select{ |pr| pr.role == "business-grants-manager"}.map(&:identity)
    else
      project_roles.where(role: "business-grants-manager").map(&:identity)
    end
  end

  def research_master_id
    sparc_protocol.research_master_id
  end

  def self.to_csv(protocols)
    CSV.generate do |csv|
      csv << ["Protocol ID", "Sparc ID", "Short Title", "Primary Principal Investigator", "Status", "IRB Approval", "IRB Expiration", "Provider/Program/Core"]
      protocols.each do |p|
        csv << [p.srid, p.sparc_id, p.short_title, p.pi ? p.pi.full_name : "", p.status.present? ? p.status.capitalize : '-',
                p.irb_approval_date.present? ? p.irb_approval_date : '-', p.irb_expiration_date.present? ? p.irb_expiration_date : '-',
                p.sub_service_request.org_tree_display]
      end
    end
  end

  ##### PRIVATE METHODS #####
  private

  def set_documents_count
    update_attributes(unaccessed_documents_count: 0) if self.unaccessed_documents_count < 0
  end
end
