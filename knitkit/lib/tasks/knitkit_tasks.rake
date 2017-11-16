require 'fileutils'

namespace :knitkit do
  namespace :website do
    desc 'Import Knitkit website and theme'
    task :import, [:website_iid, :username, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])
      user = User.find_by_username(args[:username])

      if !website and user
        puts 'Starting Import...'
        file = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.open(args[:export_path]),
          filename: File.basename(args[:export_path])
        )
        Website.import_template(file, user)
        puts 'Import Complete'
      else
        puts "Website already exists, please delete first" if website
        puts "Could not find user" unless user
      end

    end

    
    desc 'Export knitkit website'
    task :export, [:website_iid, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])

      if website

        puts 'Starting Export...'

        path = website.export_template
        FileUtils.mv(path, args[:export_path])

        puts 'Export Complete'
        
      else
        puts "Could not find website"
      end
    end
  end
  
end
