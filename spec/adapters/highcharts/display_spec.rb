require 'spec_helper.rb'

describe LazyHighCharts::HighChart do
  before { Daru::View.plotting_library = :highcharts }
  before(:each) do
  	@hc = Daru::View::Plot.new
  	@hc.chart.series(:type => "spline",
               :name => "Historias",
               :data => [0, 1, 2, 3, 5, 6, 0, 7]
    )
    @placeholder = "placeholder"
  end

  describe "#to_html" do
    it "should plot Highstock when chart_class is set to stock" do
      @hc.chart.options[:chart_class] = "stock";
      expect(@hc.chart.to_html(
      	@placeholder)
      ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.StockChart/)
    end
    it "should plot HighChart otherwise" do
      expect(@hc.chart.to_html(
      	@placeholder)
      ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.Chart/)
    end
  end
end
