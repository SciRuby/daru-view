describe Daru::View::Plot, 'Chart plotting' do
  context "initialize" do
    context "Nyaplot library" do

      let(:df) do
        Daru::DataFrame.new({
          a: [1, 3, 5, 2, 5, 0],
          b: [1, 5, 2, 5, 1, 0],
          c: [1, 6, 7, 2, 6, 0]
        }, index: 'a'..'f')
      end

      let(:dv) { Daru::Vector.new [1, 2, 3] }
      let(:lib) { Daru::View.plotting_library }
      let(:plot_df) { Daru::View::Plot.new(df) }
      let(:plot_dv) { Daru::View::Plot.new(dv) }
      it "Default plotting library Nyaplot" do
        expect(lib).to eq(:nyaplot)
      end

      it 'Nyaplot chart using DataFrame' do
        expect(plot_df).to be_a Daru::View::Plot
        expect(plot_df.chart).to be_a Nyaplot::Plot
      end

      it 'Nyaplot chart using Vector' do
        expect(plot_dv).to be_a Daru::View::Plot
        expect(plot_dv.chart).to be_a Nyaplot::Plot
      end

      it 'fails when other than DataFrame and Vector as data' do
        expect{Daru::View::Plot.new()}
        .to raise_error(ArgumentError, /Nyaplot Library, data must be in Daru::Vector or Daru::DataFrame/)
        expect{Daru::View::Plot.new([])}
        .to raise_error(ArgumentError, /Nyaplot Library, data must be in Daru::Vector or Daru::DataFrame/)
      end

    end

    context "Highcharts library" do
      before { Daru::View.plotting_library = :highcharts }
      let(:df) do
        Daru::DataFrame.new({
          a: [1, 3, 5, 2, 5, 0],
          b: [1, 5, 2, 5, 1, 0],
          c: [1, 6, 7, 2, 6, 0]
        }, index: 'a'..'f')
      end

      let(:dv) { Daru::Vector.new [1, 2, 3] }
      let(:lib) { Daru::View.plotting_library }
      let(:plot_df) { Daru::View::Plot.new(df) }
      let(:plot_dv) { Daru::View::Plot.new(dv) }
      let(:plot_array) { Daru::View::Plot.new([1,2,3]) }
      it "check plotting library" do
        expect(lib).to eq(:highcharts)
      end

      it 'Highcharts chart using Array' do
        expect(plot_array).to be_a Daru::View::Plot
        expect(plot_array.chart).to be_a LazyHighCharts::HighChart
      end

      it 'Highcharts chart using DataFrame' do
        #todo
      end

      it 'Highcharts chart using Vector' do
        #todo
      end

    end
  end # initialize context end

end