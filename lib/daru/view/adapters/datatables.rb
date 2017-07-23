require 'data_tables'
require 'daru'
require 'securerandom'

module Daru
  module View
    module Adapter
      module DatatablesAdapter
        extend self # rubocop:disable Style/ModuleFunction

        # Read : https://datatables.net/ to understand
        # the datatables option concept.
        #
        # TODO : this docs must be improved
        def init_table(data=[], options={})
          # TODO : create data array from the df and vector data
          if data.is_a?(Array)
            data_name = 'series_data'+ SecureRandom.uuid
            data =
              if data.all? { |e| e.class==Array }
                Daru::DataFrame.rows(data, name: data_name)
              else
                Daru::Vector.new(data, name: data_name)
              end
          end
          # options[:data] = data_in_array unless data_in_array.empty?
          @table = DataTables::DataTable.new(options)
          @data = data
          @table
        end

        def init_script
          DataTables.init_script
        end

        def generate_body(table)
          table_opts = {
            class: 'display',
            cellspacing: '0',
            width: '100%',
            table_html: @data.to_html_thead + @data.to_html_tbody
          }
          html_options ={
            table_options: table_opts
          }
          table.to_html(@data.name, html_options)
        end

        def export_html_file(table, path='./table.html')
          # TODO
        end

        def show_in_iruby(table)
          table.show_in_iruby
        end

        def generate_html(table)
          # TODO
        end

        def init_iruby
          DataTables.init_iruby
        end

        private

        # DataTables accept the data as Array of array.
        #
        # TODO : I didn't find use case for multi index.
        def to_data_array(data_set)
          case
          when data_set.is_a?(Daru::DataFrame)
            return ArgumentError unless data_set.index.is_a?(Daru::Index)
            data_set.access_row_tuples_by_indexs(*data_set.index.to_a)
          when data_set.is_a?(Daru::Vector)
            rows = []
            data_set.to_a.each { |a| rows << [a] }
            rows
          when data_set.is_a?(Array)
            data_set
          else
            raise ArgumentError # TODO: error msg
          end
        end
      end # DatatablesAdapter end
    end # Adapter end
  end
end
