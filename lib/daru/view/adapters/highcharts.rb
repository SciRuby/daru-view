require 'lazy_high_charts'
require_relative 'highcharts/iruby_notebook'
require_relative 'highcharts/display'
require_relative 'highcharts/core_ext/string'
require 'daru'

module Daru
  module View
    module Adapter
      module HighchartsAdapter
        extend self # rubocop:disable Style/ModuleFunction

        # Read : https://www.highcharts.com/docs/chart-concepts to understand
        # the highcharts option concept.
        #
        # TODO : this docs must be improved
        #
        # @param [Hash] options the options to create a chart with.
        # @option opts [String] :title The chart title
        # @option opts [String] :subtitle The chart subtitle
        # @option opts [String/Symbol] :type The chart type
        # @option opts [Daru::Vector / Array] :x X Axis data
        # @option opts [Daru::Vector / Array] :y Y Axis data
        # @option opts [Hash] :chart The chart options(there are many
        # options in chart Hash, same as LazyHighCahrts or HighCharts)
        # @option opts [Hash] :plotOptions The plot options, how the plot
        # type is configured
        #
        # @param [Array/Daru::DataFrame/Daru::Vector] data
        #
        def init(data=[], options={})
          # Alternate way is using `add_series` method.
          #
          # There are many options present in Highcharts so it is better to use
          # directly all the options. That means Daru::View::Plot will
          # behave same as LazyHighCharts when `data` is an Array and
          # `options` are passed.
          #
          @chart = LazyHighCharts::HighChart.new do |f|
            # all the options present in `options` and about the
            # series (means name, type, data) used in f.series(..)
            f.options = options.empty? ? LazyHighCharts::HighChart.new.defaults_options : options
            # For multiple series when data is in a series format as in
            # HighCharts official examples
            # TODO: Add support for multiple series when data as
            #   Daru::DataFrame/Daru::Vector
            if data.is_a?(Array) && data[0].is_a?(Hash)
              f.series_data = data
            else
              data_new = guess_data(data)
              series_type = options[:type] unless options[:type].nil?
              series_name = options[:name] unless options[:name].nil?
              f.series(type: series_type, name: series_name, data: data_new)
            end
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

        # Exporting in web frameworks is completely offline. In IRuby notebook,
        #   offline-export supports only the exporting to png, jpeg and svg format.
        #   Export to PDF is not working (not even through the exporting button in
        #   highchart). So, online exporting is done in IRuby notebook. There is a
        #   problem in online exporting that if we run-all all the cells of IRuby
        #   notebook then only the last chart will be exported. Individually,
        #   running the cells works fine.
        #
        # @see #Daru::View::Plot.export
        def export(plot, export_type='png', file_name='chart')
          plot.export_iruby(export_type, file_name) if defined? IRuby
        rescue NameError
          plot.export(export_type, file_name)
        end

        def show_in_iruby(plot)
          plot.show_in_iruby
        end

        def generate_html(plot)
          path = File.expand_path('../templates/highcharts/static_html.erb', __dir__)
          template = File.read(path)
          initial_script = init_script
          chart_div = generate_body(plot)
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
            data_set.access_row_tuples_by_indexs(*index_val)
          when data_set.is_a?(Daru::Vector)
            data_set.to_a
          when data_set.is_a?(Array)
            data_set
          when data_set.is_a?(String)
            # it can be `id` of html table
            data_set
          else
            # TODO: error msg
            raise ArgumentError
          end
        end
      end
    end
  end
end
