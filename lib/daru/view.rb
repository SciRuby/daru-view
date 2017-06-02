require "daru/view/version"
require "daru/view/plot"

module Daru
  module View
    @plotting_library = :nyaplot

    class << self
      attr_reader :plotting_library
      def plotting_library= lib
        case lib
        when :gruff, :nyaplot, :highcharts
          @plotting_library = lib
        else
          raise ArgumentError, "Unsupported library #{lib}"
        end
      end # def end
    end
  end
end