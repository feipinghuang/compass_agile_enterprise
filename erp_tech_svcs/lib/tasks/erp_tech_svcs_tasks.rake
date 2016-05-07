namespace :erp_tech_svcs do

  namespace :file_support do

    desc "Sync storage between database and storage location ie (s3 or file system), taskes storage option"
    task :sync_storage, [:storage] => :environment do |t, args|
      ErpTechSvcs::FileSupport::S3Manager.setup_connection
      file_support = ErpTechSvcs::FileSupport::Base.new(:storage => args.storage.to_sym)

      #sync shared
      puts "Syncing Shared Assets..."
      file_support.sync(File.join(file_support.root, 'public/knitkit/images/'), CompassAeInstance.find_by_internal_identifier('base'))
      file_support.sync(File.join(file_support.root, 'file_assets/shared_site_files/'), CompassAeInstance.find_by_internal_identifier('base'))
      puts "Complete"

      #sync websites
      puts "Syncing Websites..."
      Website.all.each do |website|
        file_support.sync(File.join(file_support.root, "public/knitkit/sites/#{website.iid}/images"), website)
        file_support.sync(File.join(file_support.root, "file_assets/sites/#{website.iid}"), website)
      end
      puts "Complete"

      #sync themes
      puts "Syncing Themes..."
      Theme.all.each do |theme|
        file_support.sync(File.join(file_support.root, theme.url), theme)
      end
      puts "Complete"
    end

  end

  namespace :database_support do

    desc "List missing indexes"
    task :list_missing_indexes => :environment do

      connection = ActiveRecord::Base.connection
      connection.tables.collect do |table|
        columns = connection.columns(table).collect(&:name).select { |x| x.ends_with?("_id" || x.ends_with("_type")) || x == 'internal_identifier' }
        indexed_columns = connection.indexes(table).collect(&:columns).flatten.uniq
        unindexed = columns - indexed_columns
        unless unindexed.empty?
          unindexed.each do |column|
            name = "#{table}_#{column}_idx"

            puts "Missing index on #{table} : #{column}"
            puts "Suggested Index"
            puts "add_index :#{table}, :#{column}, :name => '#{name}'"
            puts ""

          end
        end
      end

    end

    task :build_add_index_for_missing_index => :environment do

      connection = ActiveRecord::Base.connection
      connection.tables.collect do |table|
        columns = connection.columns(table).collect(&:name).select { |x| x.ends_with?("_id" || x.ends_with("_type")) || x == 'internal_identifier' }
        indexed_columns = connection.indexes(table).collect(&:columns).flatten.uniq
        unindexed = columns - indexed_columns
        unless unindexed.empty?
          unindexed.each do |column|
            name = "#{table}_#{column}_idx"

            puts "add_index :#{table}, :#{column}, :name => '#{name}'"

          end
        end
      end

    end

    task :build_remove_index_for_missing_index => :environment do

      connection = ActiveRecord::Base.connection
      connection.tables.collect do |table|
        columns = connection.columns(table).collect(&:name).select { |x| x.ends_with?("_id" || x.ends_with("_type")) || x == 'internal_identifier' }
        indexed_columns = connection.indexes(table).collect(&:columns).flatten.uniq
        unindexed = columns - indexed_columns
        unless unindexed.empty?
          unindexed.each do |column|
            name = "#{table}_#{column}_idx"

            puts "remove_index :#{table}, :#{column}, :name => '#{name}'"

          end
        end
      end

    end

  end

end
