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
        # Along with these options, a user can provide an additional option
        #   html_options[:table_options] to cistomize the generated table
        # See the specs of daru-data_tables gem.
        #
        # @param data [Array, Daru::DataFrame, Daru::Vector] The data provided
        #   by the user to generate the datatable
        # @param options [Hash] Various options provided by the user to
        #   incorporate in datatable
        # @return [Daru::DataTables::DataTable] Returns the datatble object
        #
        # @example DataTable
        #   Set Daru::View.table_library = :googlecharts (or set adapter option)
        #     (Also set Daru::View.dependent_script(:googlecharts) in web
        #     frameworks in head tag)
        #   Formulate the data to visualize
        #     idx = Daru::Index.new ['Year', 'Sales']
        #     data_rows = [
        #                   ['2004',  1000],
        #                   ['2005',  1170],
        #                   ['2006',  660],
        #                   ['2007',  1030]
        #                 ]
        #     df_sale_exp = Daru::DataFrame.rows(data_rows)
        #     df_sale_exp.vectors = idx
        #
        #   Set the options required
        #     options1 =  {
        #                    html_options: {
        #                      table_options: {
        #                        table_thead: "<thead>
        #                                       <tr>
        #                                       <th></th>
        #                                       <th>C1</th>
        #                                       <th>C2</th>
        #                                      </tr>
        #                                    </thead>",
        #                        width: '90%'
        #                      }
        #                    },
        #                    scrollX: true
        #                 }
        #     options2 = {searching: false}
        #
        #   Draw the Daru::View::Table object.
        #     table = Daru::View::Table.new(df_sale_exp, options1)
        #     table2 = Daru::View::Table.new(df_sale_exp, options2)
        #     table3 = Daru::View::Table.new(df_sale_exp)
        def init_table(data=[], options={}, _user_options={})
          @table = Daru::DataTables::DataTable.new(data, options)
          @table
        end

        # @return [String] returns code of the dependent JS and CSS file(s)
        def init_script
          Daru::DataTables.init_script
        end

        # @param table [Daru::DataTables::DataTable] table object to access
        #   daru-data_table methods
        # @return [String] script and table (containg thead only) tags of the
        #   datatable generated
        def generate_body(table)
          table.to_html
        end

        # @param table [Daru::DataTables::DataTable] table object to access
        #   daru-data_table methods
        # @return [void] writes the html code of the datatable to the file
        # @example
        #   table = Daru::View::Table.new(data, options)
        #   table.export_html_file
        def export_html_file(table, path='./table.html')
          path = File.expand_path(path, Dir.pwd)
          str = generate_html(table)
          File.write(path, str)
        end

        # @param table [Daru::DataTables::DataTable] table object to access
        #   daru-data_table methods
        # @return [void] shows the datatable in IRuby notebook
        # @example
        #   table = Daru::View::Table.new(data, options)
        #   table.show_in_iruby
        def show_in_iruby(table)
          table.show_in_iruby
        end

        # @param table [Daru::DataTables::DataTable] table object to access
        #   daru-data_table methods
        # @return [String] returns html code of the datatable generated
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

        # @return [void] loads the dependent JS and CSS files in IRuby notebook
        # @example
        #   table = Daru::View::Table.new(data, options)
        #   table.init_iruby
        def init_iruby
          Daru::DataTables.init_iruby
        end
      end
    end
  end
end
