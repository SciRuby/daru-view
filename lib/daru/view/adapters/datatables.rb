require 'daru/data_tables'
require 'daru'
require 'securerandom'
require 'erb'

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
          options[:data] = to_data_array(data)
          row_number = 0
          options[:data].each do |array|
            array.unshift(row_number)
            row_number += 1
          end
          @table = Daru::DataTables::DataTable.new(options)
          @table.data = data
          @table
        end

        def init_script
          Daru::DataTables.init_script
        end

        def generate_body(table)
          table_opts = {
            class: 'display',
            cellspacing: '0',
            width: '100%',
            table_html: extract_table(table)
          }
          html_options = {
            table_options: table_opts
          }
          table.element_id ||= 'series_data'+ SecureRandom.uuid
          table.to_html(table.element_id, html_options)
        end

        def export_html_file(table, path='./table.html')
          path = File.expand_path(path, Dir.pwd)
          str = generate_html(table)
          File.write(path, str)
        end

        def show_in_iruby(table)
          table.show_in_iruby
        end

        def generate_html(table)
          path = File.expand_path(
            '../templates/datatables/static_html.erb', __dir__
          )
          template = File.read(path)
          table_script = generate_body(table)
          initial_script = init_script
          id = table.element_id
          ERB.new(template).result(binding)
        end

        def init_iruby
          Daru::DataTables.init_iruby
        end

        private

        # DataTables accept the data as Array of array.
        #
        # TODO : I didn't find use case for multi index.
        def to_data_array(data_set)
          case
          when data_set.is_a?(Daru::DataFrame)
            return ArgumentError unless data_set.index.is_a?(Daru::Index)
            rows = data_set.access_row_tuples_by_indexs(*data_set.index.to_a)
            convert_to_array_of_array(rows)
          when data_set.is_a?(Daru::Vector)
            rows = []
            data_set.to_a.each { |a| rows << [a] }
            rows
          when data_set.is_a?(Array)
            convert_to_array_of_array(data_set)
          else
            raise ArgumentError # TODO: error msg
          end
        end

        def convert_to_array_of_array(rows)
          if rows.all? { |row| row.class==Array }
            rows
          else
            tuples = []
            rows.each { |row| tuples << [row] }
            tuples
          end
        end

        def extract_table(table)
          return table.data.to_html_thead unless table.data.is_a?(Array)
          path = File.expand_path(
            '../templates/datatables/thead.erb', __dir__
          )
          template = File.read(path)
          ERB.new(template).result(binding)
        end
      end
    end
  end
end
