desc 'Import Klok data'
task import_klok: :environment do

  # entries
  # projects
  # people

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  if prompt("Would you like to refresh the KlokShard with data found in tmp/klok.xml? (Y/N) ") == 'Y'
    begin
      Klok::Entry.destroy_all
      Klok::Project.destroy_all
      Klok::Person.destroy_all

      d = File.read(Rails.root.join('tmp/klok.xml'))

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
        next if entry['enabled'] == 'false'  # only solution for duplicate entries with same entry_id

        d = Klok::Entry.new
        d.attributes = entry.reject{|k,v| !d.attributes.keys.member?(k.to_s)}
        d.save
      end
    rescue Exception => e
      puts e.inspect
      puts e.backtrace.inspect
    end
  end

  ####### now that we have populated the KlokShard we can bring the same data in as line items ########

  CSV.open("tmp/klok_import_#{Time.now.strftime('%m%d%Y')}.csv", "wb") do |csv|
    csv << ["reason", "created_at", "project_id", "resource_id", "rate", "date", "start_time_stamp_formatted",
            "start_time_stamp", "entry_id", "duration", "submission_id", "device_id", "comments", "end_time_stamp_formatted",
            "end_time_stamp", "rollup_to"
           ]

    Klok::Entry.all.each do |entry|
      if entry.is_valid?

        local_protocol = entry.local_protocol
        local_identity = entry.local_identity

        service = entry.service

        line_item = LineItem.where(protocol: local_protocol, service: service).first_or_create(quantity_requested: 1, quantity_type: 'Hour')
        fulfillment = Fulfillment.where(klok_entry_id: entry.entry_id, line_item: line_item).first_or_initialize

        fulfillment.assign_attributes(fulfilled_at: entry.date.strftime('%m/%d/%Y').to_s, quantity: entry.decimal_duration, creator_id: local_identity.id, performer_id: local_identity.id,
                                      service: service, service_name: service.name, service_cost: service.cost(local_protocol.sparc_funding_source, entry.created_at))

        ### build out components
        fulfillment.components.build(component: entry.klok_project.name) if entry.klok_project.name && fulfillment.components.select{|x| x.component == entry.klok_project.name}.empty?

        ### build out notes
        fulfillment.notes.build(comment: entry.comments, identity: local_identity) if entry.comments.present? && fulfillment.notes.select{|x| (x.comment == entry.comments) && (x.identity == local_identity)}.empty?

        if fulfillment.valid?
          fulfillment.save
          csv << ["Success (SRID: #{fulfillment.protocol.srid}, fulfillment ID: #{fulfillment.id}"] + entry.attributes.values
        else
          csv << [fulfillment.errors.messages.to_s] + entry.attributes.values
        end
      else
        csv << ['Entry not valid'] + entry.attributes.values
      end
    end
  end
end
