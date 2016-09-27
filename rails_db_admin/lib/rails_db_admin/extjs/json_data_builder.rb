module RailsDbAdmin
  module Extjs
    class JsonDataBuilder

      def initialize(database_connection_class)
        @connection = database_connection_class.connection
      end

      def build_json_data(options)
        unless options[:table]
          raise '!Error Must specify table'
        end

        table = Arel::Table::new(options[:table])
        statement = table

        if options[:query_filter].present?
          accepted_columns = ActiveRecord::Base.connection.columns(options[:table]).select {|column| column.type == :string or column.type == :text}
          where_clause = nil

          accepted_columns.each_with_index do |column, index|
            if index == 0
              where_clause = table[column.name.to_sym].matches("%#{options[:query_filter]}%")
            else
              where_clause = where_clause.or(table[column.name.to_sym].matches("%#{options[:query_filter]}%"))
            end
          end

          statement = table.where(where_clause)
        end

        total_count = get_total_count(table, statement)

        if options[:limit]
          statement = statement.take(options[:limit].to_i)
        end

        if options[:offset]
          statement = statement.skip(options[:offset].to_i)
        end

        if options[:order]
          statement = statement.order(options[:order])
        end

        rows = @connection.select_all(statement.project('*'))
        records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)

        if !records.empty? && !records[0].has_key?("id")
          records = RailsDbAdmin::TableSupport.add_fake_id_col(records)
        end

        {:total => total_count, :data => records}
      end

      def get_row_data(table, id)
        arel_table = Arel::Table::new(table)

        query = arel_table.project(
        Arel.sql('*')).where(arel_table[id[0].to_sym].eq(id[1]))

        rows = @connection.select_all(query.to_sql)
        records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
        records[0]
      end

      #This will retrieve data from tables without an
      #'id' field.  Will also add a 'fake_id' so that it can
      #be used by editable ExtJS grids.
      def get_row_data_no_id(table, row_hash)
        arel_table = Arel::Table::new(table)
        query = arel_table.project(Arel.sql('*'))
        row_hash.each do |k, v|
          query = query.where(arel_table[k.to_sym].eq(v))
        end

        rows = @connection.select_all(query.to_sql)
        records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
        records = RailsDbAdmin::TableSupport.add_fake_id_col(records)
        records[0]
      end

      def get_total_count(table, statement)
        total_count = 0
        statement = statement.dup

        if ActiveRecord::Base.connection.columns(table.name).collect(&:name).include?('id')
          rows = @connection.select_all(statement.project("COUNT(id) as count"))
        else
          rows = @connection.select_all(statement.project("COUNT(*) as count"))
        end

        records = RailsDbAdmin::TableSupport.database_rows_to_hash(rows)
        total_count = records[0][:count]

        total_count
      end

    end
  end
end
