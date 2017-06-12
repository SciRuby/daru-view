module Daru
  module View
    class Plot
      attr_reader :chart
      attr_accessor :adapter

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

      def adapter=(adapter)
        require "daru/view/adapters/#{adapter}"
        @adapter = Daru::View::Adapter.const_get(
          adapter.to_s.capitalize + 'Adapter')

      end

      # display in IRuby notebook
      def show_in_iruby
        self.adapter.show_in_iruby @chart
      end

      # dependent js file, to include in head tag
      def init_script
        self.adapter.init_script
      end

      # generat html code, to include in body tag
      def div
        self.adapter.generate_body(@chart)
      end

      # generat html file
      def export_html_file(path="./plot.html")
        self.adapter.export_html_file(@chart, path)
      end

      # load the corresponding JS files in IRuby notebook.
      # This is done automatically when plotting library is set using
      # Daru::View.plotting_library = :new_library
      def init_iruby
        self.adapter.init_iruby
      end

      def add_series(data, name, type)
        case adapter
        when :highcharts
          self.add_series(data, name, type, @chart)
        else
          raise("Method `add-series` is not valid for #{self.adapter}.to_s.capitalize library.")
        end
      end

      private

      def plot_data data, options
        self.adapter = Daru::View.plotting_library
        self.adapter.init(data, options)
      end
    end
  end
end
