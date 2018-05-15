require 'spec_helper.rb'

describe LazyHighCharts do
  before { Daru::View.plotting_library = :highcharts }
  describe "#init_script" do
    it "generates valid initial script" do
      js = LazyHighCharts.init_script
      expect(js).to match(/<script type='text\/javascript'>/i)
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
      @hc.chart.options[:chart_class] = "STock";
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

  describe "#to_html_iruby" do
    it "should plot Highstock when chart_class is set to stock" do
      @hc.chart.options[:chart_class] = "SToCk";
      expect(@hc.chart.to_html_iruby(
      	@placeholder)
      ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.StockChart/)
    end
    it "should plot HighChart otherwise" do
      expect(@hc.chart.to_html_iruby(
      	@placeholder)
      ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.Chart/)
    end
  end

  describe "#extract_chart_class" do
  	it "should return the class of the chart" do
  	  @hc.chart.options[:chart_class] = "SToCk";
      expect(@hc.chart.extract_chart_class).to eq 'stock'
  	end
  	it "should return the class of the chart" do
      expect(@hc.chart.extract_chart_class).to eq nil
  	end
  end

  describe "#chart_hash_must_be_present" do
  	it "should check the presence of chart hash in options" do
  	  @hc.chart.options[:chart] = {type: :bar}
  	  @hc.chart.chart_hash_must_be_present
  	  expect(@hc.chart.options[:chart]).to eq type: :bar
  	end
  end
end
