class InvoiceReportGroupedOptions
  def initialize(organizations)
    @organizations = organizations
    @grouped_options = []
  end

  def collect_grouped_options
    @grouped_options = group_organizations(@organizations)
  end

  def add_array_to_grouped_options(array)
    @grouped_options << array unless array.nil?
  end

  def collect_organizations_with_protocols(organizations)
    organization_with_protocols = []
    organizations.each do |organization|
      if organization.has_protocols?
        organization_with_protocols << organization
      end
    end
    return organization_with_protocols
  end

  def organization_to_array(organizations, type)
    case type
      when "Institution"
        institution_array = ['Institutions', organizations.flatten.map { |institution| [institution.name, institution.id] }] unless organizations.map(&:protocols).flatten.empty?
        add_array_to_grouped_options(institution_array)
      when "Provider"
        provider_array = ['Providers', organizations.flatten.map { |provider| [provider.name, provider.id] }] unless organizations.map(&:protocols).flatten.empty?
        add_array_to_grouped_options(provider_array)
      when "Program"
        program_array = ['Programs', organizations.flatten.map { |program| [program.name, program.id] }] unless organizations.map(&:protocols).flatten.empty?
        add_array_to_grouped_options(program_array)
      when "Core"
        core_array = ['Cores', organizations.map { |core| [core.name, core.id] }] unless organizations.map(&:protocols).flatten.empty?
        add_array_to_grouped_options(core_array) 
    end
  end

  def group_organizations(organizations)

    institutions = organizations.select{|org| org.type == "Institution"}
    institutions_with_protocols = collect_organizations_with_protocols(institutions)
    organization_to_array(institutions_with_protocols, "Institution")

    providers = organizations.select{|org| org.type == "Provider"}
    providers_with_protocols = collect_organizations_with_protocols(providers)
    organization_to_array(providers_with_protocols, "Provider")

    programs = organizations.select{|org| org.type == "Program"}
    programs_with_protocols = collect_organizations_with_protocols(programs)
    organization_to_array(programs_with_protocols, "Program")
    
    

    cores = organizations.select{|org| org.type == "Core"}
    cores_with_protocols = collect_organizations_with_protocols(cores)
    organization_to_array(cores_with_protocols, "Core")
  end
end