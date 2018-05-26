describe Daru::View, "Daru::View class basic methods" do
  context "#plotting_library" do
    context 'Set plotting library to googlecharts' do
      before { Daru::View.plotting_library = :googlecharts}
      it { expect(Daru::View.plotting_library).to eq(:googlecharts) }
    end

    context 'Set plotting library to highcharts' do
      before { Daru::View.plotting_library = :highcharts}
      it { expect(Daru::View.plotting_library).to eq(:highcharts) }
    end

    context 'Set plotting library to nyaplot' do
      before { Daru::View.plotting_library = :nyaplot}
      it { expect(Daru::View.plotting_library).to eq(:nyaplot) }
    end

    context 'Set plotting library to xyz, which is unsupported' do
      it "should raise ArgumentError" do
        expect{
          Daru::View.plotting_library = :xyz_library
        }.to raise_error(ArgumentError)
      end
    end
  end

  context "#table_library" do
    context 'Set table library to googlecharts' do
      before { Daru::View.table_library = :googlecharts}
      it { expect(Daru::View.table_library).to eq(:googlecharts) }
    end

    context 'Set table library to datatables' do
      before { Daru::View.table_library = :datatables}
      it { expect(Daru::View.table_library).to eq(:datatables) }
    end

    context 'Set table library to xyz, which is unsupported' do
      it "should raise ArgumentError" do
        expect{
          Daru::View.table_library = :xyz_library
        }.to raise_error(ArgumentError)
      end
    end
  end

  context "#dependent_script" do
    it "should generate valid dependent script of highcharts" do
      script = Daru::View.dependent_script(:highcharts)
      expect(script).to match(/BEGIN highcharts.css/i)
      expect(script).to match(/END highcharts.css/i)
      expect(script).to match(/BEGIN js\/highstock.js/i)
      expect(script).to match(/Highstock JS/i)
      expect(script).to match(/END js\/highstock.js/i)
      expect(script).to match(/BEGIN highcharts-more.js/i)
      expect(script).to match(/END highcharts-more.js/i)
      expect(script).to match(/BEGIN modules\/exporting.js/i)
      expect(script).to match(/END modules\/exporting.js/i)
      expect(script).to match(/BEGIN highcharts-3d.js/i)
      expect(script).to match(/END highcharts-3d.js/i)
      expect(script).to match(/BEGIN modules\/data.js/i)
      expect(script).to match(/END modules\/data.js/i)
    end
  end

end
