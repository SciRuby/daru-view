require 'daru/view/version'
require 'daru/view/plot'
require 'daru/view/plot_list'
require 'daru/view/adapters/highcharts/display'
require 'daru/view/adapters/nyaplot/display'
require 'daru/view/adapters/googlecharts/display'
require 'daru/view/adapters/googlecharts/google_visualr'
require 'daru/view/table'

# needed in load_lib_in_iruby method
require 'daru/view/adapters/highcharts/iruby_notebook'
require 'daru/view/adapters/nyaplot/iruby_notebook'
require 'daru/view/adapters/googlecharts/iruby_notebook'

# Rails Helper
require 'daru/view/app/rails/railtie.rb' if defined?(Rails)

module Daru
  module View
    class Engine < ::Rails::Engine; end if defined?(Rails)

    # default Nyaplot library is used.
    @plotting_library = :nyaplot
    Daru::View::Plot.adapter = @plotting_library

    class << self
      attr_reader :plotting_library, :table_library

      # New plotting library is set. Same time Daru::View::Plot.adapter is set.
      def plotting_library=(lib)
        case lib
        when :nyaplot, :highcharts, :googlecharts
          # plot charts
          @plotting_library = lib
          Daru::View::Plot.adapter = lib
          if lib == :googlecharts
            # plot table drawing
            Daru::View::Table.adapter = lib
          end
        else
          raise ArgumentError, "Unsupported library #{lib}"
        end

        # When code is running in console/terminal then IRuby NameError.
        # Since IRuby methods can't work in console.
        begin
          load_lib_in_iruby lib.to_s if defined? IRuby
        rescue NameError
          return
        end
      end

      # New table library is set. Same time Daru::View::Table.adapter is set.
      def table_library=(lib)
        case lib
        when :googlecharts
          # plot chart and table drawing
          @plotting_library = @table_library = lib
          Daru::View::Plot.adapter = Daru::View::Table.adapter = lib
        when :datatables
          # only for table drawing
          @table_library = Daru::View::Table.adapter = lib
        else
          raise ArgumentError, "Unsupported library #{lib}"
        end
        # When code is running in console/terminal then IRuby NameError.
        # Since IRuby methods can't work in console.
        begin
          load_lib_in_iruby lib.to_s if defined? IRuby
        rescue NameError
          return
        end
      end

      # dependent script for the library. It must be added in the head tag
      # of the web application.
      #
      # @param lib [String, Symbol] library whose dependencies are to be loaded
      # @return [void, String] dependent script for the library
      # @example
      #   dep_js = Daru::View.dependent_script(:highcharts)
      #   use in Rails app : <%=raw dep_js %>
      # @example
      #   dep_js = Daru::View.dependent_script('highcharts')
      #   use in Rails app : <%=raw dep_js %>
      #
      # @example
      #   To load the dependent JS file for Nyaplot library
      #   plotting system (Nyaplot.js, d3.js):
      #
      #   Daru::View.dependent_script(:nyaplot)
      # @example
      #   Daru::View.dependent_script('nyaplot')
      def dependent_script(lib=:nyaplot)
        load_lib_in_iruby(lib.to_s) if defined? IRuby
      rescue NameError
        case lib.to_s
        when 'nyaplot'
          Nyaplot.init_script
        when 'highcharts'
          LazyHighCharts.init_script
        when 'googlecharts'
          GoogleVisualr.init_script
        when 'datatables'
          DataTables.init_script
        else
          raise ArgumentError, "Unsupported library #{lib}"
        end
      end

      # @param libraries [Array] libraries whose dependencies are to be
      #   loaded
      # @return [void, String] dependent script for the libraries
      #
      # @example
      #   To load the dependent JS file for Nyaplot and GoogleCharts libraries
      #   Daru::View.dependent_scripts(['nyaplot', 'googlecharts'])
      # @example
      #   To load the dependent JS file for Nyaplot and GoogleCharts libraries
      #   Daru::View.dependent_scripts([:nyaplot, :googlecharts])
      def dependent_scripts(libraries=[])
        load_libs_in_iruby(libraries) if defined? IRuby
      rescue NameError
        script = ''
        libraries.each do |library|
          script << dependent_script(library)
        end
        script
      end

      private

      # @param libraries [Array] Adapters whose JS files will be loaded
      # @return [void] load the dependent JS files for the adapter in IRuby
      #   notebook
      def load_libs_in_iruby(libraries=[])
        libraries.each do |library|
          load_lib_in_iruby(library.to_s)
        end
      end

      # Load the dependent JS files in IRuby notebook. Those JS will help in
      # plotting the charts in IRuby cell.
      def load_lib_in_iruby(library)
        if library.match('highcharts')
          library = 'LazyHighCharts'
          Object.const_get(library).init_iruby
        elsif library.match('googlecharts')
          library = 'GoogleVisualr'
          Object.const_get(library).init_iruby
        elsif library.match('datatables')
          library = 'DataTables'
          Object.const_get(library).init_iruby
        else
          Object.const_get(library.capitalize).init_iruby
        end
      end
    end
  end
end
