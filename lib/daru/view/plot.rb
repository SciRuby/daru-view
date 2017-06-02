module Daru
  module View
    class Plot
      attr_reader :plt
      attr_accessor :adapter

      # @example
      # df = Daru::DataFrame.new({a:['A', 'B', 'C', 'D', 'E'], b:[10,20,30,40,50]})
      # Daru::View::Plot.new df, type: :bar, x: :a, y: :b
      #
      def initialize(data, options= {})
        @plt = plot_data data, options
      end

      def adapter=(adapter)
        require "daru/view/adapters/#{adapter}"
        extend Module::const_get(
          "Daru::View::Adapter::#{adapter.to_s.capitalize}Adapter")
      end

      # display in IRuby notebook
      def show
        self.show(@plt)
      end

      def plot_data data, options
        self.adapter = Daru::View.plotting_library
        self.init(data, options)
      end

      # dependent js file, to include in head tag
      def init_script
        self.init_script
      end

      # generat html code, to include in body tag
      def div
        self.generate_body(@plt)
      end

      # generat html file
      def export_html(path="./plot.html")
        self.export_html(@plt, path="./plot.html")
      end


    end
  end
end
