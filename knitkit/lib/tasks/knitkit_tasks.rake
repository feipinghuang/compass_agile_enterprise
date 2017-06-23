require 'fileutils'

namespace :knitkit do
  namespace :website do

    desc 'Import Knitkit website'
    task :import, [:website_iid, :username, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])
      user = User.find_by_username(args[:username])

      if !website and user

        puts 'Starting Import...'
        file = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.open(args[:export_path]),
          filename: File.basename(args[:export_path])
        )
        Website.import(file, user)
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

        path = website.export
        FileUtils.mv(path, args[:export_path])

        puts 'Export Complete'

      else
        puts "Could not find website"
      end
    end

    desc 'Insert components for knitkit website'
    task :insert_components => :environment do |t, args|
      COMPONENTS = [ { iid: 'header1',
                       title: 'Header',
                       type: 'header',
                       thumbnail: '/images/content_blocks/header1.png',
                       height: 581 },
                     { iid: 'header2',
                       title: 'Header',
                       type: 'header',
                       thumbnail: '/images/content_blocks/header2.png',
                       height: 581 },
                     {  iid: 'container_section1',
                        title: 'Container Section',
                        type: 'container_section',
                        thumbnail: '/images/content_blocks/one_column.png',
                        height: 550 },
                     {  iid: 'container_section2',
                        title: 'Container Section',
                        type: 'container_section',
                        thumbnail: '/images/content_blocks/three_column.png',
                        height: 550 },
                     {  iid: 'content_section1',
                        title: 'Content Section',
                        type: 'content_section',
                        thumbnail: '/images/content_blocks/one_column.png',
                        height: 550 },
                     {  iid: 'content_section2',
                        title: 'Content Section',
                        type: 'content_section',
                        thumbnail: '/images/content_blocks/three_column.png',
                        height: 550 },
                     { iid: 'footer1',
                       title: 'Footer',
                       type: 'footer',
                       thumbnail: '/images/content_blocks/footer1.png',
                       height: 114 },
                     {  iid: 'footer2',
                        title: 'Footer',
                        type: 'footer',
                        thumbnail: '/images/content_blocks/footer2.png',
                        height: 245
                        }
                     ]

      Component.destroy_all
      COMPONENTS.each do |component|
        unless Component.where(internal_identifier: "#{component[:iid]}").first
          Component.create!({
                              title: component[:title],
                              body_html: component[:body_html],
                              internal_identifier: "#{component[:iid]}",
                              custom_data: { thumbnail: component[:thumbnail],
                                             height: component[:height],
                                             component_type: component[:type].downcase }
          })
        end ## unless block
      end ## Component array loop
    end ## Component insert rake task
  end

  namespace :theme do

    desc 'Import Knitkit theme'
    task :import, [:website_iid, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])

      if website

        puts 'Starting Import...'
        file = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.open(args[:export_path]),
          filename: File.basename(args[:export_path])
        )
        Theme.import(file, website)
        puts 'Import Complete'

      else
        puts "Website doesn't exists"
      end
    end

    desc 'Export knitkit theme'
    task :export, [:website_iid, :theme_id, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])
      theme = website.themes.find_by_theme_id(args[:theme_id])

      if website && theme

        puts 'Starting Export...'

        path = theme.export
        FileUtils.mv(path, args[:export_path])

        puts 'Export Complete'

      else
        puts "Could not find website" unless website
        puts "Could not find theme" unless theme
      end
    end

  end
end
