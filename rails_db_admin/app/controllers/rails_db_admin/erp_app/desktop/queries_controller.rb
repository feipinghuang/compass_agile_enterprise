module RailsDbAdmin
  module ErpApp
    module Desktop
      class QueriesController < BaseController

        def save_query
          query = params[:query]
          query_name = params[:query_name]

          @query_support.save_query(query, query_name)

          render :json => {:success => true}
        end

        def saved_queries
          names = @query_support.get_saved_query_names

          names_hash_array = []

          names_hash_array = names.collect do |name|
            {:display => name, :value => name}
          end unless names.empty?

          render :json => {:data => names_hash_array}
        end

        def delete_query
          query_name = params[:query_name]
          @query_support.delete_query(query_name)

          render :json => {:success => true}
        end

        def saved_queries_tree
          names = @query_support.get_saved_query_names

          queries = []

          queries = names.collect do |name|
            {:text => name, :id => name, :iconCls => 'icon-sql', :leaf => true}
          end unless names.empty?

          render :json => queries
        end

        def open_query
          query_name = params[:query_name]
          query = @query_support.get_query(query_name)

          render :json => {:success => true, :query => query}
        end

        def open_and_execute_query
          query_name = params[:query_name]

          query = @query_support.get_query(query_name)
          columns, values, exception = @query_support.execute_sql(query)

          if exception.nil?

            columns_array = columns.collect do |column|
              RailsDbAdmin::Extjs::JsonColumnBuilder.build_readonly_column(column)
            end

            fields_array = columns.collect do |column|
              {:name => column}
            end

            result = {:success => true, :query => query,
                      :columns => columns_array,
                      :fields => fields_array, :data => values}
          else
            result = {:success => false, :query => query,
                      :exception => exception.gsub("\n", " ")}
          end

          render :json => result
        end

        def select_top_fifty
          table = params[:table]
          sql, results = @query_support.select_top_fifty(table)

          columns = @database_connection_class.connection.columns(table)

          render :json => {:success => true,
                           :sql => sql,
                           :columns => RailsDbAdmin::Extjs::JsonColumnBuilder.build_grid_columns(columns),
                           :fields => RailsDbAdmin::Extjs::JsonColumnBuilder.build_store_fields(columns),
                           :data => results}
        end

        def execute_query
          begin
            sql = params[:sql]
            selection = params[:selected_sql]
            sql = sql.rstrip
            cursor_pos = params[:cursor_pos].to_i

            # if we have report params process them
            if params[:report_params]
              # add current_user to locals
              params[:report_params][:current_user] = current_user

              sql = RailsDbAdmin::ErbStringParser.render(sql, locals: params[:report_params])
            end

            # append a semicolon as the last character if the
            # user forgot
            if !sql.end_with?(";")
              sql << ";"
            end

            sql_arr = sql.split("\n")
            sql_stmt_arry = []
            sql_str = ""

            #search for the query to run based on cursor position if there
            #was nothing selected by the user
            if (selection == nil || selection == "")
              last_stmt_end = 0
              sql_arr.each_with_index do |val, idx|
                if val.match(';')
                  sql_stmt_arry << {:begin => (sql_stmt_arry.length > 0) ? last_stmt_end +1 : 0, :end => idx}
                  last_stmt_end = idx
                end
              end

              last_sql_stmt = sql_stmt_arry.length-1
              #run the first complete query if we're in whitespace
              #at the beginning of the text area
              if cursor_pos <= sql_stmt_arry[0].fetch(:begin)
                sql_str = sql_arr.values_at(sql_stmt_arry[0].fetch(:begin)..
                                            sql_stmt_arry[0].fetch(:end)).join(" ")
                #run the last query if we're in whitespace at the end of the
                #textarea
              elsif cursor_pos > sql_stmt_arry[last_sql_stmt].fetch(:begin)
                sql_str = sql_arr.values_at(
                  sql_stmt_arry[last_sql_stmt].fetch(:begin)..
                sql_stmt_arry[last_sql_stmt].fetch(:end)).join(" ")
                #run query based on cursor position
              else
                sql_stmt_arry.each do |sql_stmt|
                  if cursor_pos >= sql_stmt.fetch(:begin) &&
                      cursor_pos <= sql_stmt.fetch(:end)
                    sql_str = sql_arr.values_at(sql_stmt.fetch(:begin)..
                                                sql_stmt.fetch(:end)).join(" ")
                  end
                end
              end
            else
              sql_str = selection
            end

            columns, values, exception = @query_support.execute_sql(sql_str)

            if !exception.nil?
              result = {:success => false, :message => exception.gsub("\n", " ")}
            else
              exception.nil?
              columns_array = columns.collect do |column|
                RailsDbAdmin::Extjs::JsonColumnBuilder.build_readonly_column(column)
              end

              fields_array = columns.collect do |column|
                {:name => column}
              end

              result = {:success => true, :sql => sql,
                        :columns => columns_array,
                        :fields => fields_array, :data => values}
            end
            render :json => result
          rescue StandardError => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            # email notification
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            render :json => {success: false, message: ex.message}
          end
        end

        def download_csv
          begin
            sql = params[:sql]
            selection = params[:selected_sql]
            sql = sql.rstrip
            cursor_pos = params[:cursor_pos].to_i

            # append a semicolon as the last character if the
            # user forgot
            if !sql.end_with?(";")
              sql << ";"
            end

            sql_arr = sql.split("\n")
            sql_stmt_arry = []
            sql_str = ""

            #search for the query to run based on cursor position if there
            #was nothing selected by the user
            if (selection == nil || selection == "")
              last_stmt_end = 0
              sql_arr.each_with_index do |val, idx|
                if val.match(';')
                  sql_stmt_arry << {:begin => (sql_stmt_arry.length > 0) ? last_stmt_end + 1 : 0, :end => idx}
                  last_stmt_end = idx
                end
              end

              last_sql_stmt = sql_stmt_arry.length-1
              #run the first complete query if we're in whitespace
              #at the beginning of the text area
              if cursor_pos <= sql_stmt_arry[0].fetch(:begin)
                sql_str = sql_arr.values_at(sql_stmt_arry[0].fetch(:begin)..
                                            sql_stmt_arry[0].fetch(:end)).join(" ")
                #run the last query if we're in whitespace at the end of the
                #textarea
              elsif cursor_pos > sql_stmt_arry[last_sql_stmt].fetch(:begin)
                sql_str = sql_arr.values_at(
                  sql_stmt_arry[last_sql_stmt].fetch(:begin)..
                sql_stmt_arry[last_sql_stmt].fetch(:end)).join(" ")
                #run query based on cursor position
              else
                sql_stmt_arry.each do |sql_stmt|
                  if cursor_pos >= sql_stmt.fetch(:begin) &&
                      cursor_pos <= sql_stmt.fetch(:end)
                    sql_str = sql_arr.values_at(sql_stmt.fetch(:begin)..
                                                sql_stmt.fetch(:end)).join(" ")
                  end
                end
              end
            else
              sql_str = selection
            end

            columns, values, exception = @query_support.execute_sql(sql_str)

            if exception.nil?
              csv_data = CSV.generate do |csv|
                csv << columns

                values.collect(&:values).each do |row|
                  csv << row
                end
              end

              send_data csv_data,
                filename: 'query_results.csv',
                type: 'application/csv'
            else
              send_data 'Error executing sql',
                filename: 'query_results.error',
                type: 'text'
            end

          rescue StandardError => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            # email notification
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            send_data 'Error executing sql',
              filename: 'query_results.error',
              type: 'text'
          end
        end

      end #QueriesController
    end #Desktop
  end #ErpApp
end #RailsDbAdmin
