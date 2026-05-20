namespace :data do
    desc "Reset push to fulfillment flags"
    task reset_push_to_fulfillment_flags: :environment do

        require 'csv'

        csv_path = 'tmp/svc_req_pushed_input.csv' # Note to self: update this when we find out where it wants to live. tmp?

        if csv_path.blank? || !File.exist?(csv_path)
            puts "ERROR: Not a valid csv path or file not found."
            exit 1
        end

        srid_list = CSV.read(csv_path, headers: true).map { |row| row['Protocol ID (SRID)'] }.compact.uniq

        puts "*" * 50
        puts "Resetting in_work_fulfillment & imported_to_fulfillment"
        puts "CSV: #{csv_path}"
        puts "*" * 50

        reset_count = 0
        skipped_count = 0
        not_found = []

        ActiveRecord::Base.transaction do
            srid_list.each do |srid|
                protocol_id, ssr_id = srid.split('-')

                ssr = SubServiceRequest.find_by(protocol_id: protocol_id, ssr_id: ssr_id)

                if ssr.nil?
                    puts "NOT FOUND: #{srid}"
                    not_found << srid
                    next
                end

                if ssr.in_work_fulfillment? || ssr.imported_to_fulfillment?
                    ssr.update_columns(
                        in_work_fulfillment: false,
                        imported_to_fulfillment: false
                    )
                    puts "  RESET: #{srid} (id=#{ssr.id})"
                    reset_count += 1
                else
                    puts "  SKIPPED: #{srid} (id=#{ssr.id}) - flags already set to false"
                    skipped_count += 1
                end
            end
        end

        puts
        puts "*" * 50
        puts "Task completed."
        puts "  Reset: #{reset_count}"
        puts "  Skipped: #{skipped_count}"
        puts "  Not found: #{not_found.size}"

        unless not_found.empty?
            puts "\nSRIDs not found in DB:"
            not_found.each { |id| puts "  #{id}"}
        end
    end
end