require 'spec_helper.rb'

describe Daru::View::Table, 'table using daru-data_tables' do
  before { Daru::View.table_library = :datatables }
  before(:each) do
    @data_vec1 = Daru::Vector.new([1 ,2, 4], name: :a)
    @data_vec2 = Daru::Vector.new([15 ,30, 40])
    @data_df = Daru::DataFrame.new(arr1: @data_vec1, arr2: @data_vec2)
    @options = {scrollX: true}
    
    @plot = Daru::View::Table.new(@data_df, @options)
  end
  let(:options) {{scrollX: true}}
  let(:string_array) {["daru", "view"]}
  let(:data_array) {[[1, 15], [2, 30], [4, 40]]}
  let(:table_string_array) { Daru::View::Table.new(string_array, options) }
  let(:table_array) { Daru::View::Table.new(data_array, options) }
  let(:table_dv) { Daru::View::Table.new(@data_vec1, @options) }

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

  describe "#init_script" do
    subject(:js) { table_array.init_script }
    it "loads correct dependent js and css files" do
      expect(js).to match(/jquery-latest.min.js/)
      expect(js).to match(/jquery.dataTables.js/)
      expect(js).to match(/jquery.dataTables.css/)
    end
  end

  describe "#generate_body" do
    context 'when data is set as Daru::DataFrame' do
      subject(:js) { @plot.adapter.generate_body(@plot.table) }
      it 'generates valid script and table' do
        expect(js).to match(/DataTable/)
        expect(js).to match(
          /scrollX: true, data: \[\[0,1,15\],\[1,2,30\],\[2,4,40\]\]/
        )
        expect(js).to match(/<th><\/th>/i)
        expect(js).to match(/<th>arr1<\/th>/i)
        expect(js).to match(/<th>arr2<\/th>/i)
      end
    end

    # In Daru, thead is generated only when the name of the vector is provided
    context 'when data is set as Daru::Vector' do
      subject(:js) { table_dv.adapter.generate_body(table_dv.table) }
      it 'generates valid script and table' do
        expect(js).to match(/DataTable/)
        expect(js).to match(
          /scrollX: true, data: \[\[0,1\],\[1,2\],\[2,4\]\]/
        )
        expect(js).to match(/<th> <\/th>/i)
        expect(js).to match(/<th>a<\/th>/i)
      end
    end

    context 'when data is set as Array' do
      subject(:js) {
        table_string_array.adapter.generate_body(table_string_array.table)
      }
      it 'generates valid script and table' do
        expect(js).to match(/DataTable/)
        expect(js).to match(
          /scrollX: true, data: \[\[0,"daru"\],\[1,"view"\]\]/
        )
        expect(js).to match(/<th><\/th>/i)
        expect(js).to match(/<th>Column: 0<\/th>/i)
      end
    end

    context 'when data is set as Array of Arrays' do
      subject(:js) {
        table_string_array.adapter.generate_body(table_string_array.table)
      }
      it 'generates valid script and table' do
        expect(js).to match(/DataTable/)
        expect(js).to match(
          /scrollX: true, data: \[\[0,"daru"\],\[1,"view"\]\]/
        )
        expect(js).to match(/<th><\/th>/i)
        expect(js).to match(/<th>Column: 0<\/th>/i)
      end
    end
  end

  describe "#export_html_file" do
    context 'when large dataset is used' do
      before do
        array_large = []
        for i in 0..50000
          array_large << i
        end
        table_array_large = Daru::View::Table.new(array_large, options)
        table_array_large.export_html_file('./plot.html')
        @path = File.expand_path('../../plot.html', __dir__)
      end
      subject(:content) { File.read(@path) }
      it "writes correct dependent js and css files" do
        expect(content).to match(/jquery-latest.min.js/)
        expect(content).to match(/jquery.dataTables.js/)
        expect(content).to match(/jquery.dataTables.css/)
      end
      it "writes a script" do
        expect(content).to match(/html/i)
        expect(content).to match(/script/i)
      end
      it "writes server side html code of the DataTable to the file" do
        expect(content).to match(
          /data_array = \[\[0, 0\], \[1, 1\], \[2, 2\]/
        )
        expect(content).to match(
          /scrollX: true, serverSide: true, ajax:/
        )
        expect(content).to match(
          /function \( data, callback, settings \) {/)
        expect(content).to match(/out.push\( data_array\[i\] \);/i)
        expect(content).to match(/callback\( \{/i)
      end
      it "generates a table" do
        expect(content).to match(/<th><\/th>/i)
        expect(content).to match(/<th>Column: 0<\/th>/i)
      end
    end

    context 'when small dataset is used' do
      before do
        @plot.export_html_file('./plot.html')
        @path = File.expand_path('../../plot.html', __dir__)
      end
      subject(:content) { File.read(@path) }
      it "writes correct dependent js and css files" do
        expect(content).to match(/jquery-latest.min.js/)
        expect(content).to match(/jquery.dataTables.js/)
        expect(content).to match(/jquery.dataTables.css/)
      end
      it "writes a script" do
        expect(content).to match(/html/i)
        expect(content).to match(/script/i)
      end
      it "writes client side html code of the DataTable to the file" do
        expect(content).to match(/DataTable/)
        expect(content).to match(
          /scrollX: true, data: \[\[0,1,15\],\[1,2,30\],\[2,4,40\]\]/
        )
      end
      it "generates a table" do
        expect(content).to match(/<th><\/th>/i)
        expect(content).to match(/<th>arr1<\/th>/i)
        expect(content).to match(/<th>arr2<\/th>/i)
      end
    end
  end
end
