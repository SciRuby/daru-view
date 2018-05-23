require 'spec_helper.rb'

describe LazyHighCharts do
  before { Daru::View.plotting_library = :highcharts }
  describe "#generate_init_code" do
    it "generates valid initial script" do
      js = LazyHighCharts.generate_init_code(["highstock.js"])
      expect(js).to match(/BEGIN highstock.js/i)
      expect(js).to match(/Highstock JS/i)
      expect(js).to match(/END highstock.js/i)
      expect(js).to match(
        /var event = document.createEvent\(\"HTMLEvents\"\)/i)
      expect(js).to match(
        /event.initEvent\(\"load_highcharts\", false, false\)/i)
      expect(js).to match(/window.dispatchEvent\(event\)/i)
      expect(js).to match(
        /console.log\(\"Finish loading highchartsjs\"\)/i)
    end
  end
end
