require 'erb'

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
                                   (data[0].is_a?(Daru::View::Plot) ||
                                   data[0].is_a?(Daru::View::Table))
        @data = data
      end

      # display in IRuby notebook
      def show_in_iruby
        IRuby.html(div)
      end

      # generat html code, to include in body tag
      def div
        path = File.expand_path('templates/multiple_charts_div.erb', __dir__)
        template = File.read(path)
        id = []
        charts_script = extract_charts_script(id)
        ERB.new(template).result(binding)
      end

      # generate html file
      def export_html_file(path='./plot.html')
        # TODO
      end

      private

      def extract_charts_script(id=[])
        charts_script = ''
        @data.each_with_index do |plot, index|
          id[index] = ('a'..'z').to_a.shuffle.take(11).join
          # TODO: Implement this for nyplot and datatables too
          # if defined?(IRuby) && plot.is_a?(Daru::View::Plot) &&
          #    plot.chart.is_a?(LazyHighCharts::HighChart)
          #   chart_script = plot.chart.to_html_iruby(id[index])
          # else
            chart_script = plot.div(id[index])
          # end
          chart_script.sub!(%r{<div(.*?)<\/div>}ixm, '')
          charts_script << chart_script
        end
        charts_script
      end
    end
  end
end
