module Daru
  module View
    class Plot

      attr_reader :chart
      attr_accessor :adapter
      class << self

        # class method
        #
        # @example
        #
        # Daru::View::Plot.adapter = :new_library
        def adapter=(adapter)
          require "daru/view/adapters/#{adapter}"
          @@adapter = Daru::View::Adapter.const_get(
            adapter.to_s.capitalize + 'Adapter')
        end

      end

      # @example
      #
      # df = Daru::DataFrame.new({a:['A', 'B', 'C', 'D', 'E'], b:[10,20,30,40,50]})
      # Daru::View::Plot.new df, type: :bar, x: :a, y: :b
      #
      # Set the new adapter(plotting library) ,for example highcharts:
      #
      # Daru::View.plotting_library = :highcharts
      #
      def initialize(data, options= {})
        @chart = plot_data data, options
      end

      # display in IRuby notebook
      def show_in_iruby
        @adapter.show_in_iruby @chart
      end

      # dependent js file, to include in head tag
      def init_script
        @adapter.init_script
      end

      # generat html code, to include in body tag
      def div
        @adapter.generate_body(@chart)
      end

      # generat html file
      def export_html_file(path="./plot.html")
        @adapter.export_html_file(@chart, path)
      end

      # load the corresponding JS files in IRuby notebook.
      # This is done automatically when plotting library is set using
      # Daru::View.plotting_library = :new_library
      def init_iruby
        @adapter.init_iruby
      end

      def add_series(opts={})
        case adapter
        when Daru::View::Adapter::HighchartsAdapter
          @chart = @adapter.add_series(@chart, opts)
        else
          raise("Method `add-series` is not valid for #{self.adapter}.to_s.capitalize library.")
        end
      end

      private

      def plot_data data, options
        # class variable @@aapter is used in instance variable @adapter.
        # so in each object `adapter` variable can be accessed.
        @adapter = @@adapter
        @adapter.init(data, options)
      end
    end
  end
end
