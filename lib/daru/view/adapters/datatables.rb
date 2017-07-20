require 'datatables'
require 'daru'

module Daru
  module View
    module Adapter
      module GooglechartsAdapter
        extend self # rubocop:disable Style/ModuleFunction

        # Read : https://datatables.net/ to understand
        # the datatables option concept.
        #
        # TODO : this docs must be improved
        def init_table(data=[], options={})
          # TODO : create data array from the df and vector data
          data_in_array = to_data_array(data)
          options[:data] = data_in_array unless data.empty?
          @table = DataTables::DataTable.new(options)
          @table
        end

        def init_script
          DataTables.init_script
        end

        def generate_body(table)
          table.to_html
        end

        def export_html_file(plot, path='./plot.html')
          # TODO
        end

        def show_in_iruby(table)
          table.show_in_iruby
        end

        def generate_html(plot)
          # TODO
        end

        def init_iruby
          DataTables.init_iruby
        end

        private

        # DataTables accept the data as Array of array.
        #
        # TODO : Currently I didn't find use case for multi index.
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
      end # GooglechartsAdapter end
    end # Adapter end
  end
end
