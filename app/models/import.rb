# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
class Import < ApplicationRecord
  has_attached_file :file
  validates_attachment :file, content_type: { content_type: 'text/plain' }
  has_attached_file :xml_file


  def generate(file, proof_report)
    log_file = Rails.root.join('tmp', "klok_import_#{Time.now.strftime('%m%d%Y')}.csv")
    valid = true
    CSV.open(log_file, "wb") do |csv|
      dup_entry_header = true
      begin
        Klok::Entry.destroy_all
        Klok::Project.destroy_all
        Klok::Person.destroy_all

        d = File.read(file.path)

        h = Hash.from_xml(d)

        h['report']['people']['person'].each do |person|
          d = Klok::Person.new
          d.attributes = person.reject{|k,v| !d.attributes.keys.member?(k.to_s)}
          d.save
        end

        h['report']['projects']['project'].each do |project|
          d = Klok::Project.new
          d.attributes = project.reject{|k,v| !d.attributes.keys.member?(k.to_s)}
          d.save
        end

        h['report']['entries']['entry'].each do |entry|

          d = Klok::Entry.new
          d.attributes = entry.reject{|k,v| !d.attributes.keys.member?(k.to_s)}
          d.save
        end

      rescue Exception => e
        valid = false
        puts e.inspect
        puts e.backtrace.inspect
      end

      ####### now that we have populated the KlokShard we can bring the same data in as line items ########

      csv << ['']
      csv << ["ssr_id", "reason", "created_at", "project_id", "resource_id", "rate", "date", "start_time_stamp_formatted",
              "start_time_stamp", "entry_id", "duration", "submission_id", "device_id", "comments", "end_time_stamp_formatted",
              "end_time_stamp", "rollup_to", "enabled"
            ]

      puts "Populating data from KlokShard"

      Klok::Entry.all.each do |entry|

        if entry.is_valid?

          local_protocol = entry.local_protocol
          local_identity = entry.local_identity

          service = entry.service

          line_item = LineItem.where(protocol: local_protocol, service: service).first_or_create(quantity_requested: 1, quantity_type: 'Hour')
          fulfillment = Fulfillment.where(klok_entry_id: entry.entry_id, line_item: line_item).first_or_initialize

          fulfillment.assign_attributes(fulfilled_at: entry.date.strftime('%m/%d/%Y').to_s, quantity: entry.decimal_duration, creator_id: local_identity.id, performer_id: local_identity.id,
                                        service: service, service_name: service.name, service_cost: line_item.cost(local_protocol.sparc_funding_source, entry.created_at))

          ### build out components
          fulfillment.components.build(component: entry.klok_project.name) if entry.klok_project.name && fulfillment.components.select{|x| x.component == entry.klok_project.name}.empty?

          ### build out notes
          fulfillment.notes.build(comment: entry.comments, identity: local_identity) if entry.comments.present? && fulfillment.notes.select{|x| (x.comment == entry.comments) && (x.identity == local_identity)}.empty?

          if fulfillment.valid?
            unless proof_report
              fulfillment.save
            end
            csv << ["SRID: #{fulfillment.protocol.srid}", "Success (Fulfillment ID: #{fulfillment.id})"] + entry.attributes.values
          else
            csv << [fulfillment.errors.messages.to_s] + entry.attributes.values
          end
        else
          srid = entry.local_protocol.present? ? entry.local_protocol.srid : 'N/A'
          csv << ["SRID: #{srid}", "Entry not valid - Reasoning: #{entry.error_messages.to_sentence}"] + entry.attributes.values
        end
      end
    end
    [log_file, valid]
  end
end

