desc "Script to fix data after the IDS split/notify move"
task :fix_split_notify => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_file(error=false)
    puts "No import file specified or the file specified does not exist in db/imports" if error
    file = prompt "Please specify the file name to import from db/imports (must be a CSV, see db/imports/example.csv for formatting): "

    while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
      file = get_file(true)
    end

    file
  end

  puts ""
  puts "Reading in file..."
  input_file = Rails.root.join("db", "imports", get_file)
  continue = prompt('Preparing to modify the services. Are you sure you want to continue? (y/n): ')

  if (continue == 'y') || (continue == 'Y')
    ActiveRecord::Base.transaction do
      CSV.foreach(input_file, :headers => true) do |row|
      end
    end
  else
    puts "Exiting rake task..."
  end
end