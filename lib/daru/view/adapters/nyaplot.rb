
require_relative 'nyaplot/iruby_notebook'
require 'daru'

module Daru
  module View
    module Adapter
      module NyaplotAdapter
        extend self # rubocop:disable Style/ModuleFunction
        def init(data, options)
          # TODO : better code
          data_new = guess_data(data)
          data_new.plot options
        end

        def export_html_file(plot, path)
          plot.export_html path
        end

        def show_in_iruby(plot)
          plot.show
        end

        def init_script
          Nyaplot.init_script
        end

        def generate_body(plot)
          plot.to_iruby[1]
        end

        def init_iruby
          Nyaplot.init_iruby
        end

        private

        def multi_dimension_check(arr)
          arr.all? { |a| a.class==Array }
        end

        def guess_data(data_set)
          case
          when [Daru::DataFrame, Daru::Vector].include?(data_set.class)
            data_set
          when data_set.is_a?(Array)
            if data_set.empty?
              Daru::Vector.new
            else
              multi_dimension_check(data_set)? Daru::DataFrame.new(data_set) : Daru::Vector.new(data_set)
            end
          else
            raise ArgumentError, "For Nyaplot Library, data must be in
            Daru::Vector or Daru::DataFrame.\n You can change the plotting
            library using the code : \n
            ` Daru::View.plotting_library = :highcharts` or other library."
          end
        end # def end
      end
    end # Adapter end
  end
end
