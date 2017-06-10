require 'lazy_high_charts'
require_relative 'highcharts/iruby_notebook'
require_relative 'highcharts/display'

module Daru
  module View
    module Adapter
      module HighchartsAdapter
        extend self

        # Read : https://www.highcharts.com/docs/chart-concepts to understand
        # the highcharts option concept.
        def init(data, options)
          case
          when data.is_a?(Daru::DataFrame)
            # TODO : Currently I didn't find use case for multi index.
            return ArgumentError unless data.index.is_a?(Daru::Index)
            index_val = data.index.to_a
            data = data.access_row_tuples_by_indexs(*index_val)
          when data.is_a?(Daru::Vector)
            index_val = data.index.to_a
            data = data.to_a
          when data.is_a?(Array)
            data
          else
            # TODO: add more cases e.g. Array of rows
            ArgumentError
          end

          # todo : for multiple series need some modification
          @chart = LazyHighCharts::HighChart.new('graph') do |f|
            f.title({:text=> options[:title]}) unless options[:title].nil?

            series_type = options[:type]
            series_name = options[:name]
            f.series(:type=> series_type, :name=> series_name, :data=> data)
          end
          @chart
        end

        def init_script(
          dependent_js=['highcharts.js', 'highcharts-3d.js', 'highstock.js']
        )
          js =  ""
          js << "\n<script type='text/javascript'>"
          js << LazyHighCharts.generate_init_code(dependent_js)
          js << "\n</script>"
          js
        end

        def generate_body(plot)
          plot.show_in_html
        end

        def export_html_file(plot, path="./plot.html")
          path = File.expand_path(path, Dir::pwd)
          str = generate_html(plot)
          File.write(path, str)
        end

        def show_in_iruby(plot)
          plot.show_in_iruby
        end

        def generate_html(plot)
          path = File.expand_path("../../templates/highcharts/static_html.erb", __FILE__)
          template = File.read(path)
          initial_script = init_script
          chart_div = generate_body(plots)
          ERB.new(template).result(binding)
        end

        def init_iruby
          LazyHighCharts.init_iruby
        end
      end
    end # Adapter end
  end
end
