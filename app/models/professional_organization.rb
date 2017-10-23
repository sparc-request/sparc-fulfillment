class ProfessionalOrganization < ActiveRecord::Base

  include SparcShard

  belongs_to :parent, class_name: ProfessionalOrganization

   # Returns collection like [greatgrandparent, grandparent, parent].
  def parents
    parent ? (parent.parents + [parent]) : []
  end

  # Returns collection like [greatgrandparent, grandparent, parent, self].
  def parents_and_self
    parents + [self]
  end

end