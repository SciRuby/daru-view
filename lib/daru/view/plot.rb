module Daru
  module View
    class Plot
      attr_reader :chart
      attr_accessor :adapter

      # @example
      # df = Daru::DataFrame.new({a:['A', 'B', 'C', 'D', 'E'], b:[10,20,30,40,50]})
      # Daru::View::Plot.new df, type: :bar, x: :a, y: :b
      #
      def initialize(data, options= {})
        @chart = plot_data data, options
      end

      def adapter=(adapter)
        require "daru/view/adapters/#{adapter}"
        # extend Module::const_get(
        #   "Daru::View::Adapter::#{adapter.to_s.capitalize}Adapter")
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

      private

      def plot_data data, options
        self.adapter = Daru::View.plotting_library
        self.adapter.init(data, options)
      end
    end
  end
end
