# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

require 'csv'

class IncompleteVisitReport < Report
  VALIDATES_PRESENCE_OF     = [:title].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  # db columns of interest; qualified because of ambiguities
  START_DATE  = '`appointments`.`start_date`'
  END_DATE    = '`appointments`.`completed_date`'
  STATUS      = '`procedures`.`status`'
  PROTOCOL_ID = '`participants`.`protocol_id`'
  LAST_NAME   = '`participants`.`last_name`'
  FIRST_NAME  = '`participants`.`first_name`'
  VISIT_NAME  = :name

  # report columns
  REPORT_COLUMNS = ["Protocol ID (SRID)", "Patient Last Name", "Patient First Name", "Visit Name", "Start Date", "Completed Date", "List of Cores which have incomplete visits"]

  def generate(document)
    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")
    _24_hours_ago = 24.hours.ago.utc
    CSV.open(document.path, "wb") do |csv|
      csv << REPORT_COLUMNS
      result_set = Appointment.all.joins(:procedures).joins(:participant).joins(:visit_group).
                   where("#{START_DATE} < ? AND #{STATUS} = ?", _24_hours_ago, "unstarted").
                   uniq.
                   pluck(PROTOCOL_ID, LAST_NAME, FIRST_NAME, VISIT_NAME, :start_date, :completed_date, :sparc_core_name)
      get_protocol_srids(result_set)
      result_set.group_by { |x| x[0..3] }.
        map      { |x, y| [ @srid[x[0]] ] + x[1..3] << format_date(y[0][4]) << (y[0][5].nil? ? "N/A" : format_date(y[0][5])) << core_list(y) }.
        sort     { |x, y| x <=> y || 1 }. # by default, sort won't handle nils
        each     { |x|    csv << x }
    end
  end

  def get_protocol_srids(result_set)
    protocol_ids = result_set.map(&:first).uniq

    # SRID's indexed by protocol id
    @srid = Hash[Protocol.includes(:sub_service_request).
                  select(:id, :sparc_id, :sub_service_request_id). # cols necessary for SRID
                  where(id: protocol_ids).
                  map { |protocol| [protocol.id, protocol.srid] }]
  end

  def core_list(y)
    y.map(&:last).join(', ')
  end
end
