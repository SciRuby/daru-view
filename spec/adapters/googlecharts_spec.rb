require 'spec_helper.rb'

describe Daru::View::Plot, 'plotting with googlecharts' do
  before { Daru::View.plotting_library = :googlecharts }
  before(:each) do
    @data_array = [[1, 15], [2, 30], [4, 40]]
    @data_vec1 = Daru::Vector.new([1 ,2, 4])
    @data_vec2 = Daru::Vector.new([15 ,30, 40])
    @data_df = Daru::DataFrame.new(arr1: @data_vec1, arr2: @data_vec2)

    @options = {width: 800, height: 720}

    @plot = Daru::View::Plot.new(@data_df, @options)
  end

  describe "initialization Charts" do
    it "Default chart GoogleVisualr::Interactive::LineChart " do
      expect(Daru::View::Plot.new.chart).to be_a GoogleVisualr::Interactive::LineChart
    end
    it "Bar chart GoogleVisualr::Interactive::BarChart " do
      expect(Daru::View::Plot.new([], type: :bar).chart).to be_a GoogleVisualr::Interactive::BarChart
    end
    it "Column chart GoogleVisualr::Interactive::ColumnChart " do
      expect(Daru::View::Plot.new([], type: :column).chart).to be_a GoogleVisualr::Interactive::ColumnChart
    end
    # TODO: all other kinds of charts
  end

  describe "initialization Tables" do
    it "Table class must be GoogleVisualr::DataTable " do
      expect(Daru::View::Table.new.table).to be_a GoogleVisualr::DataTable
    end
  end
end
