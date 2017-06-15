require "daru/view/version"
require "daru/view/plot"

module Daru
  module View
    # default Nyaplot library is used.
    @plotting_library = :nyaplot
    Daru::View::Plot.adapter = @plotting_library

    class << self
      attr_reader :plotting_library

      # New plotting library is set. Same time Daru::View::Plot.adapter is set.
      def plotting_library= lib
        case lib
        when :gruff, :nyaplot, :highcharts
          @plotting_library = lib
        else
          raise ArgumentError, "Unsupported library #{lib}"
        end
        Daru::View::Plot.adapter = lib

        # When code is running in console/terminal then IRuby NameError.
        # Since IRuby methods can't work in console.
        begin
          load_lib_in_iruby lib.to_s.capitalize if defined? IRuby
        rescue NameError
          ;
        end
      end

      # Load the dependent JS files in IRuby notebook. Those JS will help in
      # plotting the charts in IRuby cell.
      #
      # @example
      #
      # To load the dependent JS file for Nyaplot library
      # plotting system (Nyaplot.js, d3.js):
      #
      # Daru::View.load_lib_in_iruby('Nyaplot')
      #
      # To load the HighCharts dependent JS
      # files (highcharts.js, highcharts-3d.js, highstock.js):
      #
      # Daru::View.load_lib_in_iruby('Highcharts')
      #
      def load_lib_in_iruby(library)
        require "daru/view/adapters/#{library}/iruby_notebook"
        if library.match('Highcharts')
          library = 'LazyHighCharts'
        end
        Object.const_get(library).init_iruby
      end

    end
  end
end