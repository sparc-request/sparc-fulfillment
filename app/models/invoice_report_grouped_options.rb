class InvoiceReportGroupedOptions
  def initialize(organizations)
    @organizations = organizations
    @grouped_options = []
  end

  def collect_grouped_options
    group_organizations(@organizations, "Institutions")
    group_organizations(@organizations, "Providers")
    group_organizations(@organizations, "Programs")
    group_organizations(@organizations, "Cores")
  end

  private

  def add_array_to_grouped_options(array)
    @grouped_options << array unless array.nil?
  end

  def organization_to_array(organizations, type)
    org_array = [type, organizations.flatten.map { |org| [org.name, org.id] }] unless organizations.flatten.empty?
    add_array_to_grouped_options(org_array)
  end

  def group_organizations(organizations, type)
    organizations = organizations.select{|org| org.type == type.chomp('s')}
    organization_to_array(organizations, type)
  end
end