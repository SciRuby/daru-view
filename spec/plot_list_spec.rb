describe Daru::View::PlotList, 'Charts plotting with Googlecharts library' do
  before { Daru::View.plotting_library = :googlecharts }
  let(:options) {{width: 800, height: 720}}
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
  # let(:plot_df) { Daru::View::Plot.new(df, options) }
  let(:plot_dv) { Daru::View::Plot.new(dv, type: :bar) }
  let(:table_array) { Daru::View::Table.new(
    [['col1', 'col2', 'col3'],[1, 2, 3]], options) }
  let(:plot_array) { [plot_dv, table_array] }
  let(:combined) { Daru::View::PlotList.new(plot_array) }
  context 'initialize with Googlecharts' do
    it 'sets correct data' do
      expect(combined).to be_a Daru::View::PlotList
      expect(combined.data).to eq plot_array
    end
  end
  describe '#div' do
    subject (:js) { combined.div }
    it 'genrates a table in js' do
      expect(js).to match(/<table class='columns'>/)
      expect(js).to match(/<td><div id=/)
    end
    it 'generates js of the plots' do
      expect(js).to match(/google.visualization.BarChart/)
      expect(js).to match(/google.visualization.Table/)
    end
  end
  describe '#export_html_file' do
    it 'writes valid html code of the multiple Charts to the file' do
      combined.export_html_file('./plot.html')
      path = File.expand_path('../plot.html', __dir__)
      content = File.read(path)
      expect(content).to match(/html/i)
      expect(content).to match(/loader.js/i)
      expect(content).to match(/google_visualr.js/i)
      expect(content).to match(/<script>/i)
      expect(content).to match(/Multiple Charts/i)
      expect(content).to match(/google.visualization.DataTable\(\);/i)
      expect(content).to match(/google.visualization.BarChart/)
      expect(content).to match(/google.visualization.Table/)
      expect(content).to match(/chart.draw\(data_table, \{\}/i)
    end
  end
end