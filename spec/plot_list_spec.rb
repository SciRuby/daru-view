describe Daru::View::PlotList do
  let(:df) do
    Daru::DataFrame.new(
      {
        a: [1, 2, 3, 4, 5, 6],
        b: [1, 5, 2, 5, 1, 0],
        c: [1, 6, 7, 2, 6, 0]
      }, index: 'a'..'f'
    )
  end
  let(:dv) { Daru::Vector.new [:a, :a, :a, :b, :b], type: :category }
  let(:array1) { [
      ['Galaxy', 'Distance', 'Brightness'],
      ['Canis Major Dwarf', 8000, 230.3],
      ['Sagittarius Dwarf', 24000, 4000.5],
      ['Ursa Major II Dwarf', 30000, 1412.3],
      ['Lg. Magellanic Cloud', 50000, 120.9],
      ['Bootes I', 60000, 1223.1]
    ] }
  let(:array2) { [[1, 15], [2, 30], [4, 40]] }
  let(:options_gc) {{width: 800, height: 720, adapter: :googlecharts}}
  let(:plot_gc) { Daru::View::Plot.new(array1, type: :bar, adapter: :googlecharts) }
  let(:table_gc) { Daru::View::Table.new(array1, options_gc) }
  let(:plot_hc) { Daru::View::Plot.new(
    array2, chart: { type: 'line' }, adapter: :highcharts
  ) }
  let(:plot_nyaplot) { Daru::View::Plot.new(dv, type: :bar, adapter: :nyaplot) }
  let(:plots_array) { [plot_gc, table_gc, plot_hc, plot_nyaplot] }
  let(:combined) { Daru::View::PlotList.new(plots_array) }
  context 'initialize PlotList' do
    it 'sets correct data' do
      expect(combined).to be_a Daru::View::PlotList
      expect(combined.data).to eq plots_array
    end
  end
  describe '#div' do
    subject (:js) { combined.div }
    it 'generates a table in js' do
      expect(js).to match(/<table>/)
      expect(js).to match(/<td><div id=/)
      expect(js.scan(/<td><div id=/).size).to eq(4)
    end
    context 'when js of the plots is generated' do
      it 'generates js of googlecharts' do
        expect(js).to match(/google.visualization.BarChart/)
        expect(js).to match(/google.visualization.Table/)
        expect(js).to match(
          /data_table.addColumn\({"type":"string","label":"Galaxy"}\)/
        )
        expect(js).to match(/chart.draw\(data_table, {}\)/)
        expect(js).to match(
          /data_table.addColumn\({"type":"string","label":"Canis Major Dwarf"}\)/
        )
        expect(js).to match(
          /table.draw\(data_table, {width: 800, height: 720}\)/
        )
      end
      it 'generates js of highcharts' do
        expect(js).to match(/\"chart\": { \"type\": \"line\"/)
        expect(js).to match(/Highcharts.Chart\(options\)/)
        expect(js).to match(/"data": \[ \[ 1,15 \],\[ 2,30 \],\[ 4,40 \] \]/)
      end
      it 'generates js of nyaplot' do
        expect(js).to match(/\"type\":\"bar\"/)
        expect(js).to match(/window.addEventListener\('load_nyaplot', render/)
        expect(js).to match(/"options":{"x":"data0","y":"data1"}/)
        expect(js).to match(
          /\[{"data0":"a","data1":3},{"data0":"b","data1":2}\]/
        )
      end
    end
  end
  describe '#export_html_file' do
    it 'writes valid html code of the multiple Charts to the file' do
      combined.export_html_file('./plot.html')
      path = File.expand_path('../plot.html', __dir__)
      content = File.read(path)
      expect(content).to match(/html/i)
      expect(content).to match(/loader.js/i)
      expect(content).to match(/google_visualr.js/)
      expect(content).to match(/highstock.js/)
      expect(content).to match(/require.min.js/)
      expect(content).to match(/<script>/i)
      expect(content).to match(/Multiple Charts/i)
      expect(content).to match(/google.visualization.DataTable\(\);/i)
      expect(content).to match(/google.visualization.BarChart/)
      expect(content).to match(/google.visualization.Table/)
      expect(content).to match(/chart.draw\(data_table, \{\}/i)
      expect(content).to match(/\"chart\": { \"type\": \"line\"/)
      expect(content).to match(/Highcharts.Chart/)
      expect(content).to match(/\"type\":\"bar\"/)
      expect(content).to match(/window.addEventListener\('load_nyaplot', render/)
    end
  end
end
