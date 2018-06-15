require 'google_visualr'
require_relative 'googlecharts/iruby_notebook'
require_relative 'googlecharts/display'
require 'daru'
require 'bigdecimal'
require 'daru/view/constants'

module Daru
  module View
    module Adapter
      module GooglechartsAdapter
        extend self # rubocop:disable Style/ModuleFunction

        # Read : https://developers.google.com/chart/ to understand
        # the google charts option concept.
        # and google_visualr : http://googlevisualr.herokuapp.com/
        #
        # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table,
        #   String] The data provided by the user to generate the google chart.
        #   Data in String format represents the URL of the google spreadsheet
        #   from which data has to invoked
        # @param options [Hash] Various options provided by the user to
        #   incorporate in google charts
        # @return [GoogleVisualr::Interactive] Returns the chart object based
        #   on the chart_type
        #
        # @example GoogleChart
        #   Set Daru::View.plotting_library = :googlecharts
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
        #     line_options = {
        #       title: 'Company Performance',
        #       curveType: 'function',
        #       legend: { position: 'bottom' }
        #     }
        #
        #   Draw the Daru::View::Plot object. Default chart type is Line.
        #     line_chart = Daru::View::Plot.new(df_sale_exp, line_options)
        #     bar_chart = Daru::View::Plot.new(df_sale_exp, type: :bar)
        #
        # @example GoogleChart with data as a link of google spreadsheet
        #   data = 'https://docs.google.com/spreadsheets/d/1XWJLkAwch5GXAt'\
        #          '_7zOFDcg8Wm8Xv29_8PWuuW15qmAE/gviz/tq?gid=0&headers=1&tq='
        #   query = 'SELECT H, O, Q, R WHERE O > 1'
        #   data << query
        #   options = {type: :area}
        #   chart = Daru::View::Plot.new(data, options)
        #
        # @example Multiple Charts in a row
        #   Draw the Daru::View::Plot object with the data as an array of
        #   Daru::View::Plots(s) or Daru::View::Table(s) or both
        #     combined = Daru::View::Plot([line_chart, bar_chart])
        def init(data=[], options={})
          # When multiple charts are shown in a row, @chart will contain the
          #   instance of GoogleVisular::BaseChart so that its data can contain
          #   the array of plots (this will be used in display.rb). Further,
          #   @chart will be used to call show_in_iruby and to_html.
          if data.is_a?(Array) &&
             (data[0].is_a?(Daru::View::Plot) || data[0].is_a?(Daru::View::Table))
            @chart = GoogleVisualr::BaseChart.new(GoogleVisualr::DataTable.new)
          else
            @table = GoogleVisualr::DataTable.new
            @table = get_table(data)
            validate_url(data) if data.is_a?(String)
            @chart_type = extract_chart_type(options)
            @chart = GoogleVisualr::Interactive.const_get(
              @chart_type
            ).new(@table, options)
          end
          @chart.data = data
          @chart
        end

        # @param data [Array, Daru::DataFrame, Daru::Vector, String]
        #   The data provided by the user to generate the google datatable.
        #   Data in String format represents the URL of the google spreadsheet
        #   from which data has to invoked
        # @param options [Hash] Various options provided by the user to
        #   incorporate in google datatables
        # @return [GoogleVisualr::DataTable] Returns the table object
        #
        # @example GoogleChart DataTable
        #   First, set Daru::View.plotting_library = :googlecharts
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
        #     table_options = {
        #       showRowNumber: true,
        #       width: '100%',
        #       height: '100%' ,
        #     }
        #
        #   Draw the Daru::View::Table object.
        #     line_chart = Daru::View::Table.new(df_sale_exp, table_options)
        #
        # @example GoogleChart Datatable with data as a link of google
        #   spreadsheet
        #   data = 'https://docs.google.com/spreadsheets/d/1XWJLkAwch5GXAt'\
        #          '_7zOFDcg8Wm8Xv29_8PWuuW15qmAE/gviz/tq?gid=0&headers=1&tq='
        #   query = 'SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8'
        #   data << query
        #   chart = Daru::View::Table.new(data)
        def init_table(data=[], options={})
          # if `options` is something like this :
          # {
          #   cols: [{id: 'task', label: 'Employee Name', type: 'string'},
          #          {id: 'startDate', label: 'Start Date', type: 'date'}],
          #   rows: [{c:[{v: 'Mike'}, {v: new Date(2008, 1, 28), f:'February 28, 2008'}]},
          #          {c:[{v: 'Bob'}, {v: new Date(2007, 5, 1)}]},
          #          {c:[{v: 'Alice'}, {v: new Date(2006, 7, 16)}]},
          #          {c:[{v: 'Frank'}, {v: new Date(2007, 11, 28)}]},
          #          {c:[{v: 'Floyd'}, {v: new Date(2005, 3, 13)}]},
          #          {c:[{v: 'Fritz'}, {v: new Date(2011, 6, 1)}]}
          #         ]
          # }
          # then directly DataTable is created using options. Use data=[] or nil
          @table = GoogleVisualr::DataTable.new(options)
          @table.data = data
          # When data is the URL of the spreadsheet then plot.table will
          #   contain the empty table as the DataTable is generated in query
          #   response in js and we can not retrieve the data from google
          #   spreadsheet (@see #GoogleVisualr::DataTable.draw_js_spreadsheet)
          add_data_in_table(data) unless data.is_a?(String)
          validate_url(data) if data.is_a?(String)
          @table
        end

        # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table]
        #   The data provided by the user to generate the google datatable.
        #   Data in String format represents the URL of the google spreadsheet
        #   from which data has to invoked
        # @return [GoogleVisualr::DataTable] the table object will the data
        #   filled
        def get_table(data)
          if data.is_a?(Daru::View::Table) &&
             data.table.is_a?(GoogleVisualr::DataTable)
            data.table
          elsif data.is_a?(GoogleVisualr::DataTable)
            data
          else
            add_data_in_table(data)
          end
        end

        # @param data [String] URL of the google spreadsheet from which data
        #   has to invoked
        # @return [Boolean, void] returns true for valid URL and raises error
        #   for invalid URL
        def validate_url(data)
          # `PATTERN_URL.match? data` is faster but does not support older ruby
          #  versions
          # For testing purpose, it is returning true
          return true if data.match(PATTERN_URL)
          raise 'Invalid URL'
        end

        def init_script
          GoogleVisualr.init_script
        end

        def generate_body(plot)
          plot.to_html
        end

        def export_html_file(plot, path='./plot.html')
          path = File.expand_path(path, Dir.pwd)
          str = generate_html(plot)
          File.write(path, str)
        end

        def show_in_iruby(plot)
          plot.show_in_iruby
        end

        def generate_html(plot)
          path = File.expand_path(
            '../templates/googlecharts/static_html.erb', __dir__
          )
          template = File.read(path)
          chart_script = generate_body(plot)
          initial_script = init_script
          id = plot.html_id
          ERB.new(template).result(binding)
        end

        def init_iruby
          GoogleVisualr.init_iruby
        end

        # Generally, in opts Hash, :name, :type, :data , :center=> [X, Y],
        # :size=> Integer, :showInLegend=> Bool, etc may present.
        def add_series(plot, opts={})
          plot.series(opts)
          plot
        end

        private

        def extract_chart_type(options)
          # TODO: Imprvoe this method.
          chart_type = options[:type].nil? ? 'Line' : options.delete(:type)
          chart_type = chart_type.to_s.capitalize
          chart_type = 'SteppedArea' if chart_type == 'Steppedarea'
          chart_type = 'TreeMap' if chart_type == 'Treemap'
          direct_name = %w[Map Histogram TreeMap Timeline Gauge]
          direct_name.include?(chart_type) ? chart_type : chart_type + 'Chart'
        end

        # For google table, column is needed.
        #
        # note :  1st line must be columns name and then all others
        # data rows
        #
        # TODO : Currently I didn't find use case for multi index.
        # rubocop:disable Metrics/MethodLength
        def add_data_in_table(data_set)
          case
          when data_set.is_a?(Daru::DataFrame)
            return ArgumentError unless data_set.index.is_a?(Daru::Index)
            rows = add_dataframe_data(data_set)
          when data_set.is_a?(Daru::Vector)
            rows = add_vector_data(data_set)
          when data_set.is_a?(Array)
            return GoogleVisualr::DataTable.new if data_set.empty?
            rows = add_array_data(data_set)
          when data_set.is_a?(Hash)
            @table = GoogleVisualr::DataTable.new(data_set)
            return
          else
            raise ArgumentError # TODO: error msg
          end
          @table.add_rows(rows)
          @table
        end
        # rubocop:enable Metrics/MethodLength

        def add_dataframe_data(data_set)
          rows = data_set.access_row_tuples_by_indexs(*data_set.index.to_a)
          data_set.vectors.to_a.each do |vec|
            @table.new_column(converted_type_to_js(vec, data_set), vec)
          end
          rows
        end

        def add_array_data(data_set)
          data_set[0].each_with_index do |col, indx|
            # TODO: below while loop must be improved. Similar thing for
            # above 2 cases.
            row_index = 1
            type = return_js_type(data_set[row_index][indx])
            while type.nil?
              row_index += 1
              type = return_js_type(data_set[row_index][indx])
            end
            @table.new_column(type, col)
          end
          data_set.shift # 1st row removed
          data_set
        end

        def add_vector_data(data_set)
          vec_name = data_set.name.nil? ? 'Series' : data_set.name
          @table.new_column(return_js_type(data_set[0]), vec_name)
          rows = []
          data_set.to_a.each { |a| rows << [a] }
          rows
        end

        def converted_type_to_js(vec_name, data_set)
          # Assuming all the data type is same for all the column values.
          case
          when data_set.is_a?(Daru::DataFrame)
            return_js_type(data_set[vec_name][0])
          when data_set.is_a?(Daru::Vector)
            return_js_type(data_set[0])
          end
        end

        # TODO : fix Metrics/PerceivedComplexity rubocop error
        def return_js_type(data) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          data = data.is_a?(Hash) ? data[:v] : data
          case
          when data.nil?
            return
          when data.is_a?(String)
            return 'string'
          when data.is_a?(Integer) || data.is_a?(Float) || data.is_a?(BigDecimal)
            return 'number'
          when data.is_a?(TrueClass) || data.is_a?(FalseClass)
            return 'boolean'
          when data.is_a?(DateTime)  || data.is_a?(Time)
            return 'datetime'
          when data.is_a?(Date)
            return 'date'
          end
        end
      end
    end
  end
end
