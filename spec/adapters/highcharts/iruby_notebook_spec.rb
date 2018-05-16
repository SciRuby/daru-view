require 'spec_helper.rb'

describe LazyHighCharts do
  before { Daru::View.plotting_library = :highcharts }
  describe "#init_script" do
    it "generates valid initial script" do
      js = LazyHighCharts.init_script
      expect(js).to match(/BEGIN highstock.js/i)
      expect(js).to match(/Highstock JS/i)
      expect(js).to match(/END highstock.js/i)
      expect(js).to match(/BEGIN highcharts-more.js/i)
      expect(js).to match(/END highcharts-more.js/i)
      expect(js).to match(/BEGIN modules\/exporting.js/i)
      expect(js).to match(/END modules\/exporting.js/i)
      expect(js).to match(/BEGIN highcharts-3d.js/i)
      expect(js).to match(/END highcharts-3d.js/i)
      expect(js).to match(/BEGIN modules\/data.js/i)
      expect(js).to match(/END modules\/data.js/i)
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