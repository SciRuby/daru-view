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
          @table = Daru::DataTables::DataTable.new(data, options)
          @table
        end

        def init_script
          Daru::DataTables.init_script
        end

        def generate_body(table)
          table.to_html
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
      end
    end
  end
end
