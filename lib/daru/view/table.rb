module Daru
  module View
    class Table
      attr_reader :table, :data, :options
      attr_accessor :adapter
      class << self
        # class method
        #
        # @example
        #
        # Daru::View::Table.adapter = :new_library
        def adapter=(adapter)
          # The library wrapper method for generating table is in the
          # same folder as the plotting library. Since google chart can be
          # used for plotting charts as well as table.
          #
          require "daru/view/adapters/#{adapter}"
          # rubocop:disable Style/ClassVars
          @@adapter = Daru::View::Adapter.const_get(
            adapter.to_s.capitalize + 'Adapter'
          )
          # rubocop:enable Style/ClassVars
        end
      end

      # TODO: modify the examples
      # @example
      #
      # df = Daru::DataFrame.new({a:['A', 'B', 'C', 'D', 'E'], b:[10,20,30,40,50]})
      # Daru::View::Plot.new df, type: :bar, x: :a, y: :b
      #
      # Set the new adapter(plotting library) ,for example highcharts:
      #
      # Daru::View.plotting_library = :highcharts
      #
      # To use a particular apdater in certain plot object(s), then user
      # must pass the adapter in `options` hash. e.g. `adapter: :highcharts`
      #
      def initialize(data=[], options={})
        @data = data
        @options = options
        self.adapter = options.delete(:adapter) unless options[:adapter].nil?
        @table = table_data(data, options)
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
        @adapter.show_in_iruby @table
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

      # generate html code, to include in body tag
      def div
        @adapter.generate_body(@table)
      end

      # generat html file
      def export_html_file(path='./plot.html')
        @adapter.export_html_file(@table, path)
      end

      # load the corresponding JS files in IRuby notebook.
      # This is done automatically when plotting library is set using
      # Daru::View.plotting_library = :new_library
      def init_iruby
        @adapter.init_iruby
      end

      private

      def table_data(data, options)
        # class variable @@aapter is used in instance variable @adapter.
        # so in each object `adapter` variable can be accessed.
        @adapter ||= @@adapter
        @adapter.init_table(data, options)
      end
    end
  end
end
