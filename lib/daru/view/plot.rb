module Daru
  module View
    class Plot
      attr_reader :plt
      def initialize(data, options= {})
        @plt = plot_data data, options
      end

      def adapter
        return @adapter if @adapter
        self.adapter = :nyaplot
        @adapter
      end

      def adapter=(adapter)
        require "daru/view/adapters/#{adapter}"
        @adapter = Daru::View::Adapter.const_get(
        adapter.to_s.capitalize + 'Adapter')
      end

      def show
        @plt.show
      end

      def plot_data data, options
        self.adapter.init(data, options)
      end
    end
  end
end
