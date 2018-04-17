require 'google_visualr'
require_relative 'googlecharts/iruby_notebook'
require_relative 'googlecharts/display'
require 'daru'
require 'bigdecimal'

module Daru
  module View
    module Adapter
      module GooglechartsAdapter
        extend self # rubocop:disable Style/ModuleFunction

        # Read : https://developers.google.com/chart/ to understand
        # the google charts option concept.
        # and google_visualr : http://googlevisualr.herokuapp.com/
        #
        # TODO : this docs must be improved
        def init(data=[], options={})
          @table = GoogleVisualr::DataTable.new
          @table = get_table(data)
          @chart_type = extract_chart_type(options)
          @chart = GoogleVisualr::Interactive.const_get(
            @chart_type
          ).new(@table, options)
          @chart.data = data
          @chart
        end

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
          # then directly DatTable is created using options. Use data=[] or nil
          @table = GoogleVisualr::DataTable.new(options)
          @table.data = data
          add_data_in_table(data)
          @table
        end

        def get_table(data)
          if data.is_a?(Daru::View::Table) && data.table.is_a?(GoogleVisualr::DataTable)
            data.table
          elsif data.is_a?(GoogleVisualr::DataTable)
            data
          elsif data.is_a?(String)
            GoogleVisualr::DataTable.new
          else
            add_data_in_table(data)
          end
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
          path = File.expand_path('../templates/googlecharts/static_html.erb', __dir__)
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
        def add_data_in_table(data_set) # rubocop:disable Metrics/MethodLength
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
