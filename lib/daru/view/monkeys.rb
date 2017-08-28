module Daru
  class DataFrame
    # @example
    #
    # df = Daru::DataFrame.new([1, 2, 3, 4, 5])
    # df.plot(adapter: :googlecharts)
    #
    # Note: `options` can take options same as Daru::View::Plot(df, options)
    def plot options={}
      Daru::View::Plot.new(self, options)
    end
  end
end