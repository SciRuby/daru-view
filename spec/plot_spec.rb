describe Daru::View::Plot, 'Chart plotting with Nyaplot library' do
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
  let(:lib) { Daru::View.plotting_library }
  let(:plot_df) { Daru::View::Plot.new(df, type: :line, x: :a, y: :c) }
  let(:plot_dv) { Daru::View::Plot.new(dv, type: :line) }
  context 'initialize' do
    # before { Daru::View.plotting_library = :nyaplot }
    context 'Default plotting_library is nyaplot' do
      it { expect(Daru::View.plotting_library).to eq(:nyaplot)}
    end

    context 'chart using DataFrame' do
      it { expect(plot_df).to be_a Daru::View::Plot }
      it { expect(plot_df.chart.class).to eq Nyaplot::Plot }
      it { expect(plot_df.data).to eq df}
      it { expect(plot_df.options).to eq type: :line, x: :a, y: :c}
    end

    context 'chart using Vector' do
      it { expect(plot_dv).to be_a Daru::View::Plot }
      it { expect(plot_dv.chart).to be_a Nyaplot::Plot }
      it { expect(plot_dv.data).to eq dv}
      it { expect(plot_dv.options).to eq type: :line}
    end

    context 'fails when other than DataFrame and Vector is as data' do
      # expect{Daru::View::Plot.new()}
      # .to raise_error(ArgumentError,
      # /Nyaplot Library, data must be in Daru::Vector or Daru::DataFrame/)
    end
  end
end

describe Daru::View::Plot, 'Chart plotting with Highcharts library' do
  context 'initialize with Nyaplot library' do
    context 'Highcharts library' do
      before { Daru::View.plotting_library = :highcharts }
      let(:lib) { Daru::View.plotting_library }
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
      let(:plot_df) { Daru::View::Plot.new(df, type: :line, x: :a, y: :c) }
      let(:plot_dv) { Daru::View::Plot.new(dv, type: :line) }
      let(:plot_array) { Daru::View::Plot.new([1, 2, 3], type: :line) }
      it 'check plotting library' do
        expect(lib).to eq(:highcharts)
      end

      it 'Highcharts chart using Array' do
        expect(plot_array).to be_a Daru::View::Plot
        expect(plot_array.chart).to be_a LazyHighCharts::HighChart
        expect(plot_array.data).to eq [1, 2, 3]
        expect(plot_array.options).to eq type: :line
      end

      it 'Highcharts chart using DataFrame' do
        expect(plot_df).to be_a Daru::View::Plot
        expect(plot_df.chart).to be_a LazyHighCharts::HighChart
        expect(plot_df.data).to eq df
        expect(plot_df.options).to eq type: :line, x: :a, y: :c
      end

      it 'Highcharts chart using Vector' do
        expect(plot_dv).to be_a Daru::View::Plot
        expect(plot_dv.chart).to be_a LazyHighCharts::HighChart
        expect(plot_dv.data).to eq dv
        expect(plot_dv.options).to eq type: :line
      end
    end
  end # initialize context end
end

describe Daru::View::Plot, 'Chart plotting with Googlecharts library' do
  before { Daru::View.plotting_library = :googlecharts }
  let(:lib) { Daru::View.plotting_library }
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
  let(:plot_df) { Daru::View::Plot.new(df, options) }
  let(:plot_dv) { Daru::View::Plot.new(dv, options) }
  let(:plot_array) { Daru::View::Plot.new(
    [['col1', 'col2', 'col3'],[1, 2, 3]], options) }
  context 'initialize with Googlecharts library' do
    it 'check plotting library' do
      expect(lib).to eq(:googlecharts)
    end

    it 'Googlecharts chart using Array' do
      expect(plot_array).to be_a Daru::View::Plot
      expect(plot_array.chart).to be_a GoogleVisualr::Interactive::LineChart
      expect(plot_array.data).to eq [[1, 2, 3]]
      expect(plot_array.options).to eq options
    end

    it 'Googlecharts chart using DataFrame' do
      expect(plot_df).to be_a Daru::View::Plot
      expect(plot_df.chart).to be_a GoogleVisualr::Interactive::LineChart
      expect(plot_df.data).to eq df
      expect(plot_df.options).to eq options
    end

    it 'Googlecharts chart using Vector' do
      expect(plot_dv).to be_a Daru::View::Plot
      expect(plot_dv.chart).to be_a GoogleVisualr::Interactive::LineChart
      expect(plot_dv.data).to eq dv
      expect(plot_dv.options).to eq options
    end
  end # initialize context end
  context '#export' do
    it "generates valid script to export a chart to png" do
      js = plot_df.export('png', 'daru')
      expect(js).to match(/google.visualization.DataTable\(\);/)
      expect(js).to match(/google.visualization.LineChart/)
      expect(js).to match(/a.href = chart.getImageURI()/)
      expect(js).to match(/a.download = 'daru.png'/)
    end
    it "generates valid script to export a chart to pdf" do
      js = plot_dv.export('pdf', 'daru')
      expect(js).to match(/google.visualization.DataTable\(\);/)
      expect(js).to match(/google.visualization.LineChart/)
      expect(js).to match(/var doc = new jsPDF()/)
      expect(js).to match(/doc.addImage\(chart.getImageURI\(\), 0, 0\)/)
      expect(js).to match(/doc.save\('daru.pdf'\)/)
    end
  end
end
