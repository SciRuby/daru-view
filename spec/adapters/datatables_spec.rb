require 'spec_helper.rb'

describe Daru::View::Table, 'table using daru-data_tables' do
  before { Daru::View.table_library = :datatables }
  before(:each) do
    @data_array = [[1, 15], [2, 30], [4, 40]]
    @string_array = [[1, 15], ["daru", "view"]]

    @data_vec1 = Daru::Vector.new([1 ,2, 4])
    @data_vec2 = Daru::Vector.new([15 ,30, 40])
    @data_df = Daru::DataFrame.new(arr1: @data_vec1, arr2: @data_vec2)

    @options = {width: 800, height: 720}

    @plot = Daru::View::Table.new(@data_df, @options)
  end

  describe "initialization Tables" do
    it "Table class must be Daru::DataTables::DataTable" do
      expect(Daru::View::Table.new.table).to be_a Daru::DataTables::DataTable
    end

    it "Table class must be Daru::DataTables::DataTable when data objects" \
       " are not of class Array" do
      expect(Daru::View::Table.new(@string_array, @options).table).to be_a Daru::DataTables::DataTable
    end

    it "Table class must be Daru::DataTables::DataTable when data objects" \
       " are of class Array" do
      expect(Daru::View::Table.new(@data_array, @options).table).to be_a Daru::DataTables::DataTable
    end
  end
end
