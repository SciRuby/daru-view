require 'spec_helper.rb'

describe Daru::View::Table, 'table using daru-data_tables' do
  before { Daru::View.table_library = :datatables }
  before(:each) do
    @data_vec1 = Daru::Vector.new([1 ,2, 4])
    @data_vec2 = Daru::Vector.new([15 ,30, 40])
    @data_df = Daru::DataFrame.new(arr1: @data_vec1, arr2: @data_vec2)
    @options = {width: 800, height: 720}
    
    @plot = Daru::View::Table.new(@data_df, @options)
  end
  let(:options) {{width: 800, height: 720}}
  let(:string_array) {["daru", "view"]}
  let(:data_array) {[[1, 15], [2, 30], [4, 40]]}
  let(:table_string_array) { Daru::View::Table.new(string_array, options) }
  let(:table_array) { Daru::View::Table.new(data_array, options) }

  describe "initialization Tables" do
    it "Table class must be Daru::DataTables::DataTable" do
      expect(Daru::View::Table.new.table).to be_a Daru::DataTables::DataTable
    end

    it "Table class must be Daru::DataTables::DataTable when data objects" \
       " are of class Array" do
      expect(table_string_array.table).to be_a Daru::DataTables::DataTable
      expect(table_string_array.data).to eq string_array
      expect(table_string_array.options).to eq options
    end

    it "Table class must be Daru::DataTables::DataTable when data objects" \
       " are of class Array of Arrays" do
      expect(table_array.table).to be_a Daru::DataTables::DataTable
      expect(table_array.data).to eq data_array
      expect(table_array.options).to eq options
    end
  end
end
