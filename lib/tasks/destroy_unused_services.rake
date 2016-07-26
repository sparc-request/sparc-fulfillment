namespace :data do
  desc "Delete unused services AND pricing maps"

  task destroy_unused_services: :environment do |t, args|

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def get_file(error=false)
      puts "No import file specified or the file specified does not exist in db/imports" if error
      file = prompt "Please specify the file name to import from db/imports (must be a CSV, see db/imports/example.csv for formatting): "
      puts ""
      continue = prompt "Preparing to delete unused services!  Press any key to continue or CTRL-C to exit"
      puts ""
      while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
        file = get_file(true)
      end

      file
    end

    file = get_file
    input_file = Rails.root.join('db', 'imports', file)
    count = 0
    CSV.foreach(input_file, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
      id = row["Service ID"]
      service = Service.where(id: id).first
      if service.line_items.empty?
        service.destroy
        service.pricing_maps.each(&:destroy)
        count += 1
        puts count
      end
    end
    puts "#{count} services destroyed."
  end
end
