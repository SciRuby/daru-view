require 'lazy_high_charts'

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

            data = data.access_row_tuples_by_indexs(index_val)
          when data.is_a?(Daru::Vector)
            data.plot options
          else
            # TODO: add more cases e.g. Array of rows
            ArgumentError
          end

          # todo : for multiple series need some modification
          @chart = LazyHighCharts::HighChart.new('graph') do |f|
            f.title({:text=> options[:title]}) unless options[:title].nil?

            f.series[:type] = options[:type] unless options[:type].nil?
            f.series[:name] = options[:name] unless options[:name].nil?
            f.series[:data] = data
          end
        end

        def init_script

        end

        def generate_body(plot)
          #todo
        end

        def export_html(plot, path="./plot.html")
          #todo
        end

        def show
          #todo
        end

      end
    end # Adapter end
  end
end
