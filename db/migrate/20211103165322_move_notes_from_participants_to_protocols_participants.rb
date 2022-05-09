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
  has_paper_trail
end

class MoveNotesFromParticipantsToProtocolsParticipants < ActiveRecord::Migration[5.2]
  def change
    CSV.open(Rails.root.join("tmp/participant_notes_exceptions.csv"), "wb") do |csv|
      csv << ["Note ID", "Participant ID", "Error:"]

      #establish the date/time when the first protocol participant was created
      note_date = "2019-05-16 17:50:00".to_datetime
      notes_bar = ProgressBar.new(Note.where('notes.notable_type = ? AND notes.created_at <= ?', "Participant", note_date).count)

      #find each of the notes with type as Participant created before the above date/time
      Note.where('notes.notable_type = ? AND notes.created_at <= ?', "Participant", note_date).find_each do |note|
        participant = note.notable

        #If we can't find the participant, add note to the csv, and skip to the next record
        if !participant
          csv << [note.id, note.notable_id, "Participant could not be found"]
          notes_bar.increment!
          next
        end

        #check each of the previous versions for the one with the most recent protocol_id
        latest_version_with_protocol_id_change = participant.versions.select{|version| YAML::load(version.object_changes)["protocol_id"]}.last

        #if we can't find a valid version with a protocol id, add note to the csv, and skip to the next record
        if !latest_version_with_protocol_id_change
          csv << [note.id, note.notable_id, "Could not find past version with protocol id"]
          notes_bar.increment!
          next
        end

        #grab the protocol_id 
        protocol_id = YAML::load(latest_version_with_protocol_id_change.object_changes)["protocol_id"].last.to_i

        #find the protocols_participant associated with the participant
        protocols_participant = participant.protocols_participants.where(protocol_id: protocol_id).first

        #if we can't find the protocols_participant, add note to the csv, and skip to the next record
        if !protocols_participant
          csv << [note.id, note.notable_id, "Protocols Participant could not be found, protocol_id: #{protocol_id}"]
          notes_bar.increment!
          next
        end

        #assign the note to the protocols_participant
        note.notable = protocols_participant
        note.save
      
        notes_bar.increment!
      end

      csv << [""]
      csv << [""]
      csv << [""]
      csv << [""]
      
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
