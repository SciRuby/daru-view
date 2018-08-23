describe Daru::View::Table, 'Generating Table with Googlecharts library' do
  context 'initialize with Googlecharts library' do
    before do
      Daru::View.table_library = :googlecharts 
    end
    let(:options) {{width: 800, height: 720}}
    let(:lib) { Daru::View.table_library }
    let(:df) do
      Daru::DataFrame.new(
        {
          a: [1, 2, 3, 4, 5, 6],
          b: [1, 5, 2, 5, 1, 0],
          c: [1, 6, 7, 2, 6, 0]
        }, index: 'a'..'f'
      )
    end
    let(:dv) { Daru::Vector.new [1, 2, 3] }
    let(:array) {[['col1', 'col2', 'col3'],[1, 2, 3]]}
    let(:table_df) { Daru::View::Table.new(df, options) }
    let(:table_dv) { Daru::View::Table.new(dv, options) }
    let(:table_array) { Daru::View::Table.new(array, options) }

    it 'check table library' do
      expect(lib).to eq(:googlecharts)
    end

    it 'Googlecharts table using Array' do
      expect(table_array).to be_a Daru::View::Table
      expect(table_array.table).to be_a GoogleVisualr::DataTable
      expect(table_array.options).to eq options
      expect(table_array.data).to eq array
    end

    it 'Googlecharts table using DataFrame' do
      expect(table_df).to be_a Daru::View::Table
      expect(table_df.table).to be_a GoogleVisualr::DataTable
      expect(table_df.options).to eq options
      expect(table_df.data).to eq df
    end

    it 'Googlecharts table using Vector' do
      expect(table_dv).to be_a Daru::View::Table
      expect(table_dv.table).to be_a GoogleVisualr::DataTable
      expect(table_dv.options).to eq options
      expect(table_dv.data).to eq dv
    end
  end # initialize context end
end

describe Daru::View::Table, 'Generating Table with daru-data_tables library' do
  context 'initialize with daru-data_tables library' do
    before { Daru::View.table_library = :datatables }
    let(:options) {{width: 800, height: 720}}
    let(:lib) { Daru::View.table_library }
    let(:df) do
      Daru::DataFrame.new(
        {
          a: [1, 2, 3, 4, 5, 6],
          b: [1, 5, 2, 5, 1, 0],
          c: [1, 6, 7, 2, 6, 0]
        }, index: 'a'..'f'
      )
    end
    let(:dv) { Daru::Vector.new [1, 2, 3] }
    let(:table_df) { Daru::View::Table.new(df, options) }
    let(:table_dv) { Daru::View::Table.new(dv, options) }
    it 'check table library' do
      expect(lib).to eq(:datatables)
    end

    it 'daru-data_tables table using DataFrame' do
      expect(table_df).to be_a Daru::View::Table
      expect(table_df.table).to be_a Daru::View::DataTable
      expect(table_df.options).to eq options
      expect(table_df.data).to eq df
    end

    it 'daru-data_tables table using Vector' do
      expect(table_dv).to be_a Daru::View::Table
      expect(table_dv.table).to be_a Daru::View::DataTable
      expect(table_dv.options).to eq options
      expect(table_dv.data).to eq dv
    end
  end # initialize context end
end
