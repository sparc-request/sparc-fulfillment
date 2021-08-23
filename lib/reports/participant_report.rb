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

class ParticipantReport < Report
  VALIDATES_PRESENCE_OF = [:title].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def generate(document)
    #We want to filter from 00:00:00 in the local time zone,
    #then convert to UTC to match database times
    @start_date = Time.strptime(@params[:start_date], "%m/%d/%Y").utc unless !@params[:end_date].present? || !@params[:start_date].present?
    #We want to filter from 11:59:59 in the local time zone,
    #then convert to UTC to match database times
    @end_date   = Time.strptime(@params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second unless !@params[:start_date].present? || !@params[:end_date].present?

    @gender = @params[:gender] unless @params[:gender] == 'Both' || @params[:gender] == ''
    @mrns = @params[:mrns]
    @protocols = @params[:protocols]
    @protocol_level = @params[:protocol_level]

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, "wb") do |csv|
      conditions = {:mrn => @mrns, :gender => @gender, :date_of_birth => @start_date..@end_date}
      conditions.delete_if {|k,v| !v.present? || v.to_s == ".." }
      participants = 
        if @protocols
          Participant.eager_load(:protocols).joins(:protocols_participants).where(conditions).where(protocols_participants: { protocol_id: @protocols }).distinct
        else
          Participant.eager_load(:protocols).where(conditions).distinct
        end

      if @start_date || @gender
        csv << ["Chosen Filters:"]
      end

      if @start_date
        csv << ["From Date of Birth", format_date(Time.strptime(@params[:start_date], "%m/%d/%Y")), "To Date of Birth", format_date(Time.strptime(@params[:end_date], "%m/%d/%Y"))]
      end

      if @gender
        csv << ["Gender", @gender]
      end

      header = ["Participant ID"]
      header << "De-identified"
      header << "First Name"
      header << "Middle Initial"
      header << "Last Name"
      header << "MRN"
      header << "Date of Birth"
      header << "Gender"
      header << "Ethnicity"
      header << "Race"
      header << "Address"
      header << "Phone"
      header << "City"
      header << "State"
      header << "Zip"
      if @protocol_level
        header << "External ID"
        header << "Current Arm"
        header << "Status"
        header << "Recruitment Source"
      else
        header << "Protocol(s)"
      end

      csv << header
      participants.each do |participant|
        deidentified = participant.deidentified == false ? "No" : participant.deidentified == true ? "Yes" : "N/A"

        data = [participant.id]
        data << deidentified
        data << participant.first_name
        data << participant.middle_initial
        data << participant.last_name
        data << "MRN: #{participant.mrn}"
        data << participant.date_of_birth
        data << participant.gender
        data << participant.ethnicity
        data << participant.race
        data << participant.address
        data << participant.phone
        data << participant.city
        data << participant.state
        data << participant.zipcode

        if @protocol_level
          ##There is only one protocol in the protocols array, because this is being ran inside of one protocol
          protocol_id = @protocols.first
          ##Same with protocols_participant, only one should exist between this particular participant, and protocol
          protocols_participant = participant.protocols_participants.where(protocol_id: protocol_id).first
          arm = protocols_participant.arm

          data << protocols_participant.external_id
          data << arm.nil? ? "No Arm Selected" : arm.name
          data << protocols_participant.status
          data << protocols_participant.recruitment_source
        else
          data << participant.protocols.map(&:sparc_id).map(&:inspect).join(', ')
        end

        csv << data
      end
      
    end
  end
end

