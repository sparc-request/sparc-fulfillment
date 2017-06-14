class Version < ActiveRecord::Base
  include PaperTrail::VersionConcern
end
