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
        #
        # todo : this docs must be improved
        # options :
        # => :x
        # => :y
        # => :data
        # => :type
        # => :name
        # => :chart
        #       => :type
        #       => :options3d
        #       => :margin
        # => :title
        # => :subtitle
        # => :plotOptions
        #
        # @param [Hash] options the options to create a chart with.
        # @option opts [String] :title The chart title
        # @option opts [String] :subtitle The chart subtitle
        # @option opts [String/Symbol] :type The chart type
        # @option opts [Daru::Vector / Array] :x X Axis data
        # @option opts [Daru::Vector / Array] :y Y Axis data
        # @option opts [Hash] :chart The chart options(there are many options in chart Hash, same as LazyHighCahrts or HighCharts)
        # @option opts [Hash] :plotOptions The plot options, how the plot type is configured
        #
        # @param [Array/Daru::DataFrame/Daru::Vector] data
        #
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
            # TODO: error msg
            raise ArgumentError
          end

          # todo : for multiple series need some modification
          @chart = LazyHighCharts::HighChart.new('graph') do |f|
            # chart option may contains : :type, :options3d, :margin
            f.chart(options[:chart]) unless options[:chart].nil?

            f.title({:text=> options[:title]}) unless options[:title].nil?
            f.subtitle({:text=> options[:subtitle]}) unless options[:subtitle].nil?

            series_type = options[:type] unless options[:type].nil?
            series_name = options[:name] unless options[:name].nil?
            f.series(:type=> series_type, :name=> series_name, :data=> data)

            f.plotOptions(options[:plotOptions]) unless options[:plotOptions].nil?
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
