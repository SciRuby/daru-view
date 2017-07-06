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
    before { Daru::View.plotting_library = :nyaplot }
    context 'chart using DataFrame' do
      it { expect(plot_df).to be_a Daru::View::Plot }
      it { expect(plot_df.chart.class).to eq Nyaplot::Plot }
    end

    context 'chart using Vector' do
      it { expect(plot_dv).to be_a Daru::View::Plot }
      it { expect(plot_dv.chart).to be_a Nyaplot::Plot }
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
      let(:plot_array) { Daru::View::Plot.new([1, 2, 3]) }
      it 'check plotting library' do
        expect(lib).to eq(:highcharts)
      end

      it 'Highcharts chart using Array' do
        expect(plot_array).to be_a Daru::View::Plot
        expect(plot_array.chart).to be_a LazyHighCharts::HighChart
      end

      it 'Highcharts chart using DataFrame' do
        # todo
      end

      it 'Highcharts chart using Vector' do
        # todo
      end
    end
  end # initialize context end
end

describe Daru::View::Plot, 'Chart plotting with Googlecharts library' do
  context 'initialize with Googlecharts library' do
    context 'Googlecharts library' do
      before { Daru::View.plotting_library = :googlecharts }
      let(:lib) { Daru::View.plotting_library }
      let(:plot_array) { Daru::View::Plot.new(
        [['col1', 'col2', 'col3'],[1, 2, 3]]) }
      it 'check plotting library' do
        expect(lib).to eq(:googlecharts)
      end

      it 'Googlecharts chart using Array' do
        expect(plot_array).to be_a Daru::View::Plot
        expect(plot_array.chart).to be_a GoogleVisualr::Interactive::LineChart
      end

      it 'Googlecharts chart using DataFrame' do
        # todo
      end

      it 'Googlecharts chart using Vector' do
        # todo
      end
    end
  end # initialize context end
end
