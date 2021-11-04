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

class Participant < ApplicationRecord
  has_many :notes, as: :notable
  has_many :protocols_participants, dependent: :destroy
end

class MoveNotesFromParticipantsToProtocolsParticipants < ActiveRecord::Migration[5.2]
  def change
    CSV.open(Rails.root.join("tmp/participant_notes_exceptions.csv"), "wb") do |csv|
      csv << ["Participant ID:", "Notes Count:", "Note IDs:"]

      bar = ProgressBar.new(Participant.count)

      Participant.includes(:notes).find_each do |participant|
        if participant.notes.with_deleted.empty?##No notes to move over
          bar.increment!

        elsif participant.protocols_participants.with_deleted.empty?##No protocols_participants to move notes TO, needs to be left alone, and added to report.
          csv << [participant.id, participant.notes.with_deleted.count, participant.notes.with_deleted.map(&:id).join(" | ")]
          csv << ["----", "Skipped Notes:"]

          participant.notes.with_deleted.each do |note|
            csv << ["", "--", note.comment]
          end

          bar.increment!
        else
          participant.notes.with_deleted.each do |note|
            args = note.attributes.except('id', 'notable_type', 'notable_id')

            participant.protocols_participants.with_deleted.each do |prot_part|
              prot_part.notes.create(args)
            end

            note.really_destroy!
          end

          bar.increment!
        end
      end
    end
    bar2 = ProgressBar.new(Note.where(notable_type: "Participant").count)
    ##Clear out notes that have no participant in the first place
    Note.with_deleted.where(notable_type: "Participant").each do |note|
      if Participant.find_by_id(note.notable_id).nil?
        note.really_destroy!
      end
    end
  end
end
