require 'erb'
require 'daru/view/adapters/highcharts/display'
require 'daru/view/adapters/nyaplot/display'
require 'daru/view/adapters/googlecharts/display'

# Otherwise Daru::IRuby module was used and IRuby.html method was not working.
# rubocop:disable Style/MixinUsage
include IRuby::Utils if defined?(IRuby)
# rubocop:enable Style/MixinUsage

module Daru
  module View
    class PlotList
      attr_reader :data

      # @example
      #
      # Daru::View.plotting_library = :googlecharts
      #
      # df = Daru::DataFrame.new({a:['A', 'B', 'C', 'D', 'E'], b:[10,20,30,40,50]})
      # plot1 = Daru::View::Plot.new(
      #   df, type: :bar, x: :a, y: :b
      # )
      # plot2 = Daru::View::Plot.new(
      #   df, type: :column, x: :a, y: :b
      # )
      # plots = Daru::View::PlotList.new([plot1, plot2])
      #
      def initialize(data=[])
        raise ArgumentError unless data.is_a?(Array) &&
                                   data.all? { |plot|
                                     plot.is_a?(Daru::View::Plot) ||
                                     plot.is_a?(Daru::View::Table)
                                   }
        @data = data
      end

      # display in IRuby notebook
      def show_in_iruby
        IRuby.html(div)
      end

      # generate html code, to include in body tag
      def div
        path = File.expand_path('templates/multiple_charts_div.erb', __dir__)
        template = File.read(path)
        id = []
        charts_script = extract_charts_script(id)
        ERB.new(template).result(binding)
      end

      # generate html file
      def export_html_file(path='./plot.html')
        path = File.expand_path(path, Dir.pwd)
        str = generate_html
        File.write(path, str)
      end

      private

      def extract_charts_script(id=[])
        charts_script = ''
        @data.each_with_index do |plot, index|
          id[index] = ('a'..'z').to_a.shuffle.take(11).join
          chart_script = extract_chart_script(id, plot, index)
          chart_script.sub!(%r{<div(.*?)<\/div>}ixm, '')
          charts_script << chart_script
        end
        charts_script
      end

      def extract_chart_script(id, plot, index)
        # TODO: Implement this for nyplot and datatables too
        if defined?(IRuby.html) && plot.is_a?(Daru::View::Plot) &&
           plot.chart.is_a?(LazyHighCharts::HighChart)
          chart_script = plot.chart.to_html_iruby(id[index])
        elsif plot.is_a?(Daru::View::Plot) && plot.chart.is_a?(Nyaplot::Plot)
          raise NotImplementedError, 'Not yet implemented'
        else
          chart_script = plot.div(id[index])
        end
        chart_script
      end

      def generate_html
        path = File.expand_path(
          'templates/static_html_multiple_charts.erb', __dir__
        )
        template = File.read(path)
        charts_script = div
        set_init_script = {}
        initial_script = ''
        @data.each do |plot|
          adapter = plot.adapter
          unless set_init_script[adapter]
            set_init_script[adapter] = true
            initial_script << plot.adapter.init_script
          end
        end
        ERB.new(template).result(binding)
      end
    end
  end
end
