require 'spec_helper.rb'

describe LazyHighCharts do
  before { Daru::View.plotting_library = :highcharts }
  describe "#init_script" do
    it "generates valid initial script" do
      js = LazyHighCharts.init_script
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