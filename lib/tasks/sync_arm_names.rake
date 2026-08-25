# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

namespace :data do
    desc "Sync Fulfillment arm names to match SPARC Request arm names"
    task sync_fulfillment_arm_names: :environment do
        require 'csv'

        input_file  = Rails.root.join('tmp', 'change_fulfil_to_sparc_input.csv')
        output_file = Rails.root.join('tmp', 'change_fulfil_to_sparc_output.csv')

        puts "Looking for input file at: #{input_file}"
        puts "File exists? #{File.exist?(input_file)}"

        output_headers = [
            "Protocol ID (SRID)", "Old Fulfillment Arm Name", "New Arm Name (SPARC)", "Status", "Details"
        ]

        updated_count = 0
        skipped_count= 0

        CSV.open(output_file, "w", write_headers: true, headers: output_headers) do |csv|
            CSV.foreach(input_file, headers: true, col_sep: ',', liberal_parsing: true, encoding: 'bom|utf-8') do |row|
                display_id = row["Protocol ID (SRID)"]&.strip
                new_name = row ["SPARC Request Arms Names"]&.strip

                next if display_id.blank? && new_name.blank?

                unless display_id.present? && display_id.match?(/^\d+-\d+$/)
                    puts "Cannot read SRID on row: #{row.inspect}."
                    csv << [display_id, nil, new_name, "Error", "Cannot read Protocol ID (SRID)"]
                    skipped_count += 1
                    next
                end

                protocol_id, ssr_id = display_id.split("-")
                formatted_ssr_id = "%04d" % ssr_id.to_i

                if new_name.blank?
                    csv << [display_id, nil, new_name, "Error", "New SPARC arm name is blank"]
                    skipped_count += 1
                    next
                end

                ssr = SubServiceRequest.find_by(ssr_id: formatted_ssr_id, protocol_id: protocol_id)

                unless ssr
                    csv << [display_id, nil, new_name, "Error", "SSR not found"]
                    skipped_count += 1
                    next
                end

                protocol = ssr.service_request&.protocol

                unless protocol
                    csv << [display_id, nil, new_name, "Error", "Fulfillment protocol not found"]
                    skipped_count += 1
                    next
                end

                arms = protocol.arms

                if arms.count.zero?
                    new_arm = protocol.create_arm(name: new_name, subject_count: 1, visit_count: 1)

                    if new_arm.persisted?
                        csv << [display_id, nil, new_name, "Created (placeholder)", "New Fulfillment arm created with minimal required data (subject_count: 1, visit_count: 1)"]
                        updated_count += 1
                    else
                        csv << [display_id, nil, new_name, "Error", new_arm.errors.full_messages.join(";")]
                        skipped_count += 1
                    end
                    next
                elsif arms.count > 1
                    csv << [display_id, arms.map(&:name).join(" | "), new_name, "Error", "Protocol has #{arms.count} Fulfillment arms. Expected 1. Cannot determine which arm this row refers to"]
                    skipped_count += 1
                    next
                end

                arm = arms.first
                old_name = arm.name

                if old_name == new_name
                    csv << [display_id, old_name, new_name, "Skipped", "Name already matches"]
                    skipped_count += 1
                    next
                end

                if arm.update(name: new_name)
                    csv << [display_id, old_name, new_name, "Updated", ""]
                    updated_count += 1
                else
                    csc << [display_id, old_name, new_name, "Error", arm.errors.full_messages.join("; ")]
                    skipped_count += 1
                end
            end
        end

        puts "Done. Updated/Created: #{updated_count}, Skipped/Errors: #{skipped_count}"
        puts "Results written to #{output_file}"
    end

    desc "Sync SPARC Request arm names to match Fulfillment Request arm names"
    task sync_sparc_arm_names: :environment do
        require 'csv'

        input_file  = Rails.root.join('tmp', 'change_sparc_to_fulfill_input.csv')
        output_file = Rails.root.join('tmp', 'change_sparc_to_fulfill_output.csv')

        puts "Looking for input file at: #{input_file}"
        puts "File exists? #{File.exist?(input_file)}"

        output_headers = [
            "Protocol ID (SRID)", "Old SPARC Arm Name", "New Arm Name (Fulfillment)", "Status", "Details"
        ]

        updated_count = 0
        skipped_count= 0

        CSV.open(output_file, "w", write_headers: true, headers: output_headers) do |csv|
            CSV.foreach(input_file, headers: true, col_sep: ',', liberal_parsing: true, encoding: 'bom|utf-8') do |row|
                display_id = row["Protocol ID (SRID)"]&.strip
                new_name = row ["Fulfillment Arm Name"]&.strip

                next if display_id.blank? && new_name.blank?

                unless display_id.present? && display_id.match?(/^\d+-\d+$/)
                    puts "Cannot read SRID on row: #{row.inspect}."
                    csv << [display_id, nil, new_name, "Error", "Cannot read Protocol ID (SRID)"]
                    skipped_count += 1
                    next
                end

                protocol_id, ssr_id = display_id.split("-")
                formatted_ssr_id = "%04d" % ssr_id.to_i

                if new_name.blank?
                    csv << [display_id, nil, new_name, "Error", "New Fulfillment arm name is blank"]
                    skipped_count += 1
                    next
                end

                ssr = SubServiceRequest.find_by(ssr_id: formatted_ssr_id, protocol_id: protocol_id)

                unless ssr
                    csv << [display_id, nil, new_name, "Error", "SSR not found"]
                    skipped_count += 1
                    next
                end

                fulfillment_protocol = ssr.service_request&.protocol
                sparc_protocol = fulfillment_protocol&.sparc_protocol

                unless sparc_protocol
                    csv << [display_id, nil, new_name, "Error", "SPARC Request protocol not found"]
                    skipped_count += 1
                    next
                end

                arms = sparc_protocol.arms

                if arms.count.zero?
                    new_arm = sparc_protocol.arms.create(name: new_name, subject_count: 1, visit_count: 1)

                    if new_arm.persisted?
                        csv << [display_id, nil, new_name, "Created (placeholder)", "New SPARC arm created with minimal required data (subject_count: 1, visit_count: 1)"]
                        updated_count += 1
                    else
                        csv << [display_id, nil, new_name, "Error", new_arm.errors.full_messages.join(";")]
                        skipped_count += 1
                    end
                    next
                elsif arms.count > 1
                    csv << [display_id, arms.map(&:name).join(" | "), new_name, "Error", "Protocol has #{arms.count} SPARC arms. Expected 1. Cannot determine which arm this row refers to"]
                    skipped_count += 1
                    next
                end

                arm = arms.first
                old_name = arm.name

                if old_name == new_name
                    csv << [display_id, old_name, new_name, "Skipped", "Name already matches"]
                    skipped_count += 1
                    next
                end

                if arm.update(name: new_name)
                    csv << [display_id, old_name, new_name, "Updated", ""]
                    updated_count += 1
                else
                    csv << [display_id, old_name, new_name, "Error", arm.errors.full_messages.join("; ")]
                    skipped_count += 1
                end
            end
        end

        puts "Done. Updated/Created: #{updated_count}, Skipped/Errors: #{skipped_count}"
        puts "Results written to #{output_file}"
    end

    desc "Run both arm name sync tasks (Fulfill to SPARC, then SPARC to Fulfill)"
    task sync_arm_names: [:sync_fulfillment_arm_names, :sync_sparc_arm_names]
end
