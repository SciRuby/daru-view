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
        def init(data=GoogleVisualr::DataTable.new, options={})
          @table = add_data_in_table(
            data) unless data.is_a?(GoogleVisualr::DataTable)
          series_type = options[:type].nil? ? 'Line' : options[:type]
          @chart = GoogleVisualr::Interactive.const_get(
          series_type.to_s.capitalize + 'Chart').new(@table, options)
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
          add_data_in_table(data)
          @table
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
          # TODO: modify code
          path = File.expand_path('../../templates/googlecharts/chart_div.erb', __FILE__)
          template = File.read(path)
          initial_script = init_script
          chart_script = generate_body(plots)
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

        def add_data_in_table(data_set)
          case
          when data_set.is_a?(Daru::DataFrame)
            # TODO : Currently I didn't find use case for multi index.
            return ArgumentError unless data_set.index.is_a?(Daru::Index)
            index_val = data_set.index.to_a
            df_rows = data_set.access_row_tuples_by_indexs(*index_val)
            data_set.vectors.each do |vec|
              @table.new_column(converted_type_to_js(vec, data_set) , vec)
            end
            @table.add_rows(df_rows)
          when data_set.is_a?(Daru::Vector)
            vec_name = data_set.name.nil? ? 'Series' : data_set.name
            @table.new_column(return_js_type(data_set[0]) , vec_name)
            vec_rows = []
            data_set.to_a.each { |a| vec_rows << [a] }
            @table.add_rows(vec_rows)
          when data_set.is_a?(Array)
            if data_set.empty?
              return
            end
            # For google table column is needed.
            #
            # note :  1st line must be colmns name and then all others
            # data rows
            vec_name = data_set[0] # for this 1st line must be Name of col
            data_set.shift # 1st row removed
            data_set.vectors.each_with_index do |vec, indx|
              @table.new_column(return_js_type(data_set[0][indx]), vec)
            end
            @table.add_rows(data_set)
          else
            # TODO: error msg
            raise ArgumentError
          end
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

        def return_js_type(data)
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
            when data.is_a?(DateTime)  || data.is_a?(Time)
              return 'time'
            when data.is_a?(Date)
              return 'date'
          end
        end
      end # GooglechartsAdapter end
    end # Adapter end
  end
end
