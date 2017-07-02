require 'spec_helper.rb'

describe Daru::View::Plot, 'plotting with googlecharts' do
  before { Daru::View.plotting_library = :googlecharts }
  before(:each) do
    @data_array = [[1, 15], [2, 30], [4, 40]]
    @data_vec1 = Daru::Vector.new([1 ,2, 4])
    @data_vec2 = Daru::Vector.new([15 ,30, 40])
    @data_df = Daru::DataFrame.new(arr1: @data_vec1, arr2: @data_vec2)

    @options = {width: 800, height: 720}

    @plot = Daru::View::Plot.new(@data, @options)
  end

  describe "initialization" do
    # TODO
  end
end
