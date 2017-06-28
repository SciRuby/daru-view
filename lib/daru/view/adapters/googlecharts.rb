require 'google_visualr'
require_relative 'googlecharts/iruby_notebook'
require_relative 'googlecharts/display'
require 'daru'

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
          data_new = guess_data(data)
          @chart = LazyHighCharts::HighChart.new do |f|
            # all the options present in `options` and about the
            # series (means name, type, data) used in f.series(..)
            f.options = options.empty? ? LazyHighCharts::HighChart.new.defaults_options : options

            series_type = options[:type] unless options[:type].nil?
            series_name = options[:name] unless options[:name].nil?
            f.series(type: series_type, name: series_name, data: data_new)
          end
          @chart
        end

        def init_script
          LazyHighCharts.init_script
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
          path = File.expand_path('../../templates/highcharts/static_html.erb', __FILE__)
          template = File.read(path)
          initial_script = init_script
          chart_div = generate_body(plots)
          ERB.new(template).result(binding)
        end

        def init_iruby
          LazyHighCharts.init_iruby
        end

        # Generally, in opts Hash, :name, :type, :data , :center=> [X, Y],
        # :size=> Integer, :showInLegend=> Bool, etc may present.
        def add_series(plot, opts={})
          plot.series(opts)
          plot
        end

        private

        def guess_data(data_set)
          case
          when data_set.is_a?(Daru::DataFrame)
            # TODO : Currently I didn't find use case for multi index.
            return ArgumentError unless data_set.index.is_a?(Daru::Index)
            index_val = data_set.index.to_a
            df_rows = data_set.access_row_tuples_by_indexs(*index_val)
            return [data_set.vectors, df_rows]
          when data_set.is_a?(Daru::Vector)
            vec_name = data_set.name.nil? ? 'Series' : data_set.name
            return [Array(vec_name), data_set.to_a]
          when data_set.is_a?(Array)
            # note : See 1st line colmns name and then data rows
            vec_name = data_set[0] # for this 1st line must be Name of col
            data_set.shift # 1st row removed
            return [vec_name, data_set]
          else
            # TODO: error msg
            raise ArgumentError
          end
        end
      end # HighchartsAdapter end
    end # Adapter end
  end
end
