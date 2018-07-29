module Daru
  module View
    class Plot
      attr_reader :chart, :data, :options, :user_options
      attr_accessor :adapter
      class << self
        # class method
        #
        # @example
        #
        # Daru::View::Plot.adapter = :googlecharts
        #
        # Plotting libraries are nyaplot, highcharts, googlecharts
        def adapter=(adapter)
          require "daru/view/adapters/#{adapter}"
          # rubocop:disable Style/ClassVars
          @@adapter = Daru::View::Adapter.const_get(
            adapter.to_s.capitalize + 'Adapter'
          )
          # rubocop:enable Style/ClassVars
        end
      end

      # @example
      #
      # df = Daru::DataFrame.new({a:['A', 'B', 'C', 'D', 'E'], b:[10,20,30,40,50]})
      # Daru::View::Plot.new df, type: :bar, x: :a, y: :b, adapter: :nyaplot
      #
      # Set the new adapter(plotting library) ,for example highcharts:
      #
      # Daru::View.plotting_library = :highcharts
      #
      # To use a particular adapter in certain plot object(s), then user
      # must pass the adapter in `options` hash. e.g. `adapter: :highcharts`
      #
      def initialize(data=[], options={}, user_options={}, &block)
        # TODO: &block is not used, right now.
        @data = data
        @options = options
        @user_options = user_options
        self.adapter = options.delete(:adapter) unless options[:adapter].nil?
        @chart = plot_data(data, options, user_options, &block)
      end

      # instance method
      def adapter=(adapter)
        require "daru/view/adapters/#{adapter}"
        @adapter = Daru::View::Adapter.const_get(
          adapter.to_s.capitalize + 'Adapter'
        )
      end

      # display in IRuby notebook
      def show_in_iruby
        @adapter.show_in_iruby @chart
      end

      # dependent js file, to include in head tag using the plot object.
      # @example:
      # plot_obj.init_script
      #
      # Note :
      # User can directly put the dependent script file into the head tag
      # using `Daru::View.dependent_script(:highcharts), by default it loads
      # Nyaplot JS files.
      #
      def init_script
        @adapter.init_script
      end

      # generat html code, to include in body tag
      def div
        @adapter.generate_body(@chart)
      end

      # generat html file
      def export_html_file(path='./plot.html')
        @adapter.export_html_file(@chart, path)
      end

      # @param type [String] format to which chart has to be exported
      # @param file_name [String] The name of the file after exporting the chart
      # @return [String, void] js code of chart along with the code to export it
      #   and loads the js code to export it in IRuby.
      # @example Export a HighChart
      #   data = Daru::Vector.new([5 ,3, 4])
      #   hchart = Daru::View::Plot.new(data)
      #   hchart.export('png', 'daru')
      def export(export_type='png', file_name='chart')
        @adapter.export(@chart, export_type, file_name)
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
          raise("Method `add-series` is not valid for #{@adapter}.to_s.capitalize library.")
        end
      end

      private

      def plot_data(data, options, user_options)
        # class variable @@aapter is used in instance variable @adapter.
        # so in each object `adapter` variable can be accessed.
        @adapter ||= @@adapter
        @adapter.init(data, options, user_options)
      end
    end
  end
end
