require 'fileutils'

module RailsDbAdmin
  class QuerySupport

    def initialize(database_connection_class, database_connection_name)
      @path = File.join(Rails.root, Rails.application.config.rails_db_admin.query_location, database_connection_name)
      @connection = database_connection_class.connection
    end

    def execute_sql(sql)
      begin
        result = @connection.execute(sql)
      rescue => ex
        return nil, nil, ex.message
      end

      values = []
      columns = []

      if @connection.class == ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        columns = result.fields

        if result && result.count > 0
          result.each do |row|
            values << HashWithIndifferentAccess.new(row)
          end
        end
      elsif @connection.class == ActiveRecord::ConnectionAdapters::Mysql2Adapter
        columns = result.fields

        if result && result.count > 0
          result.each do |row|
            result_hash = {}
            columns.zip(row) { |key,value| result_hash[key] = value }
            values << HashWithIndifferentAccess.new(result_hash)
          end
        end
      else
        columns = result[0].keys
        result.each do |row|
          values << HashWithIndifferentAccess.new(row)
        end
      end

      return columns, values, nil
    end

    def select_top_fifty(table)
      #Actually, sanitizing here is pretty redundant since it's a constant...
      ar = Arel::Table::new(table)
      query = ar.project(Arel.sql('*')).take(50)
      #query = "SELECT * FROM #{table} LIMIT #{@connection.sanitize_limit(50)}"

      # This is a temporary partial fix to handle postgres boolean columns which is use activerecord when possible
      begin
        rows = table.classify.constantize.find_by_sql(query.to_sql)
      rescue
        rows = @connection.select_all(query.to_sql)
      end

      records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)

      return query.to_sql, records
    end

    def get_saved_query_names
      query_files = []

      if File.directory? @path
        query_files = Dir.entries(@path)
        query_files.delete_if { |name| name =~ /^\./ }
        query_files.each do |file_name|
          file_name.gsub!('.sql', '')
        end
      end

      query_files
    end

    def save_query(query, name)
      FileUtils.mkdir_p(@path) unless File.directory? @path

      file_path = File.join(@path, "#{name}.sql")
      File.new(file_path, 'w') unless File.exist?(File.join(file_path))
      File.open(file_path, 'w+') { |f| f.puts(query) }
    end

    def delete_query(name)
      FileUtils.rm(File.join(@path, "#{name}.sql")) if File.exist?(File.join(@path, "#{name}.sql"))
    end

    def get_query(name)
      File.open(File.join(@path, "#{name}.sql")) { |f| f.read } if File.exist?(File.join(@path, "#{name}.sql"))
    end

  end
end
