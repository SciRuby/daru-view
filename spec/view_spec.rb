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
      expect(script).to match(/BEGIN modules\/exporting.js/i)
      expect(script).to match(/END modules\/exporting.js/i)
      expect(script).to match(/BEGIN highcharts-3d.js/i)
      expect(script).to match(/END highcharts-3d.js/i)
      expect(script).to match(/BEGIN modules\/data.js/i)
      expect(script).to match(/END modules\/data.js/i)
    end
  end

  context "#dependent_scripts" do
    context 'when String Array is given as parameter' do
      let(:script_str) {
        Daru::View.dependent_scripts(['googlecharts', 'nyaplot'])
      }
      it "generates dependent JS of googlecharts" do
        expect(script_str).to match(/BEGIN google_visualr.js/)
        expect(script_str).to match(/END google_visualr.js/)
        expect(script_str).to match(/BEGIN loader.js/)
        expect(script_str).to match(/END loader.js/)
      end
      it "generates dependent JS of nyaplot" do
        expect(script_str).to match(/http:\/\/cdnjs.cloudflare.com/)
        expect(script_str).to match(/"downloadable":"http:\/\/cdn.rawgit.com/)
        expect(script_str).to match(/"d3":"https:\/\/cdnjs.cloudflare.com/)
      end
    end
    context 'when Symbol Array is given as parameter' do
      let(:script) {
        Daru::View.dependent_scripts(
          [:googlecharts, :nyaplot, :highcharts, :datatables]
        )
      }
      it "generates dependent script of highcharts" do
        expect(script).to match(/BEGIN highcharts.css/i)
        expect(script).to match(/END highcharts.css/i)
        expect(script).to match(/BEGIN js\/highstock.js/i)
        expect(script).to match(/END js\/highstock.js/i)
        expect(script).to match(/BEGIN modules\/exporting.js/i)
        expect(script).to match(/END modules\/exporting.js/i)
        expect(script).to match(/BEGIN highcharts-3d.js/i)
        expect(script).to match(/END highcharts-3d.js/i)
        expect(script).to match(/BEGIN modules\/data.js/i)
        expect(script).to match(/END modules\/data.js/i)
      end
      it "generates dependent JS of googlecharts" do
        expect(script).to match(/BEGIN google_visualr.js/)
        expect(script).to match(/END google_visualr.js/)
        expect(script).to match(/BEGIN loader.js/)
        expect(script).to match(/END loader.js/)
      end
      it "generates dependent JS of nyaplot" do
        expect(script).to match(/http:\/\/cdnjs.cloudflare.com/)
        expect(script).to match(/"downloadable":"http:\/\/cdn.rawgit.com/)
        expect(script).to match(/"d3":"https:\/\/cdnjs.cloudflare.com/)
      end
      it "generates dependent JS of datatables" do
        expect(script).to match(/BEGIN jquery.dataTables.css/)
        expect(script).to match(/END jquery.dataTables.css/)
        expect(script).to match(/BEGIN jquery\-latest.min.js/)
        expect(script).to match(/END jquery\-latest.min.js/)
        expect(script).to match(/BEGIN jquery.dataTables.js/)
        expect(script).to match(/END jquery.dataTables.js/)
      end
    end
  end
end
