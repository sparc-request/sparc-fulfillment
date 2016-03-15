class InvoiceReportGroupedOptions
  def initialize(organizations)
    @organizations = organizations
    @grouped_options = []
  end

  def collect_grouped_options
    @grouped_options = group_organizations(@organizations) || []
  end

  def add_array_to_grouped_options(array)
    @grouped_options << array unless array.nil?
  end

  def organization_to_array(organizations, type)
    case type
      when "Institution"
        institution_array = ['Institutions', organizations.flatten.map { |institution| [institution.name, institution.id] }] unless organizations.flatten.empty?
        add_array_to_grouped_options(institution_array)
      when "Provider"
        provider_array = ['Providers', organizations.flatten.map { |provider| [provider.name, provider.id] }] unless organizations.flatten.empty?
        add_array_to_grouped_options(provider_array)
      when "Program"
        program_array = ['Programs', organizations.flatten.map { |program| [program.name, program.id] }] unless organizations.flatten.empty?
        add_array_to_grouped_options(program_array)
      when "Core"
        core_array = ['Cores', organizations.map { |core| [core.name, core.id] }] unless organizations.flatten.empty?
        add_array_to_grouped_options(core_array) 
    end
  end

  def group_organizations(organizations)

    institutions = organizations.select{|org| org.type == "Institution"}
    organization_to_array(institutions, "Institution")

    providers = organizations.select{|org| org.type == "Provider"}
    organization_to_array(providers, "Provider")

    programs = organizations.select{|org| org.type == "Program"}
    organization_to_array(programs, "Program")

    cores = organizations.select{|org| org.type == "Core"}
    organization_to_array(cores, "Core")
  end
end