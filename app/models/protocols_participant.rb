class ProtocolsParticipant < ApplicationRecord
  belongs_to :protocol
  belongs_to :participant
  belongs_to :arm
end