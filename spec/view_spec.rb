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
        expect{Daru::View.plotting_library = :xyz_library}.to raise_error(ArgumentError)
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

  end

end