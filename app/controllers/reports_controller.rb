class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]
  before_action :find_report_type, only: [:new, :create]

  def new
    @title = @report_type.titleize
    @organizations = current_identity.fulfillment_organizations

    # @protocols = current_identity.fulfillment_organizations.map(&:protocols)

    @grouped_options = []



    # institutions = @organizations.where(type: 'Institution')
    institutions = current_identity.fulfillment_organizations.select{|org| org.type == "Institution"}
    instituion_with_protocols = []

    institutions.each do |institution|
      if institution.has_protocols?
        instituion_with_protocols << institution
      end
    end
    
    providers = current_identity.fulfillment_organizations.select{|org| org.type == "Provider"}
    providers_with_protocols = []

    providers.each do |provider|
      if provider.has_protocols?
        providers_with_protocols << provider
      end
    end
    
    
    programs = current_identity.fulfillment_organizations.select{|org| org.type == "Program"}
    programs_with_protocols = []

    programs.each do |program|
      if program.has_protocols?
        programs_with_protocols << program
      end
    end
    
    cores = current_identity.fulfillment_organizations.select{|org| org.type == "Core"}
    cores_with_protocols = []

    cores.each do |core|
      if core.has_protocols?
        cores_with_protocols << core
      end
    end

    institution_array = ['Institutions', institutions_with_protocols.map { |institution| [institution.name, institution.id] }] unless institutions.map(&:protocols).flatten.empty?
    provider_array = ['Providers', providers_with_protocols.map { |provider| [provider.name, provider.id] }] unless providers.map(&:protocols).flatten.empty?
    program_array = ['Programs', programs_with_protocols.map { |program| [program.name, program.id] }] unless programs.map(&:protocols).flatten.empty?
    core_array = ['Cores', cores_with_protocols.map { |core| [core.name, core.id] }] unless cores.map(&:protocols).flatten.empty?

    
    add_array_to_grouped_options(institution_array)
    add_array_to_grouped_options(provider_array)
    add_array_to_grouped_options(program_array)
    add_array_to_grouped_options(core_array)
  end



  def create
    @document = Document.new(title: reports_params[:title].humanize, report_type: @report_type)
    @report = @report_type.classify.constantize.new(reports_params)

    @errors = @report.errors
    
    if @report.valid?
      @reports_params = reports_params
      @documentable.documents.push @document
      ReportJob.perform_later(@document, reports_params)
    end
  end

  def add_array_to_grouped_options(array)
    @grouped_options << array unless array.nil?
  end

  def update_dropdown
    org_ids = params[:org_ids]

    @protocols = []
    if org_ids.length > 1 
      org_ids.each do |org_id|
        @protocols << find_protocols(org_id)
      end
    else
      @protocols << find_protocols(org_ids)
    end
    @protocols = @protocols.flatten

  end

  private

  def find_protocols(org_ids)
    orgs = Array.wrap(Organization.find(org_ids))
    org_protocols =[]

    orgs.each do |org|
      org_protocols << org.protocols
    end
    return org_protocols.flatten
  end

  def find_documentable
    if params[:documentable_id].present? && params[:documentable_type].present?
      @documentable = params[:documentable_type].constantize.find params[:documentable_id]
    else
      @documentable = current_identity
    end
  end

  def find_report_type
    @report_type = reports_params[:report_type]
  end

  def reports_params
    params.require(:report_type) # raises error if report_type not present

    params.permit(:format,
              :utf8,
              :report_type,
              :title,
              :start_date,
              :end_date,
              :time_zone,
              :protocol_id,
              :participant_id,
              :documentable_id,
              :documentable_type,
              :protocol_ids => []).merge(identity_id: current_identity.id)
  end
end
