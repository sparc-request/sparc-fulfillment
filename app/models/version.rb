class Version < ApplicationRecord
  include PaperTrail::VersionConcern
end
