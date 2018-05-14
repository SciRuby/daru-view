require 'spec_helper.rb'

# refer lazy_high_charts_spec.rb here: 
#   https://github.com/michelson/lazy_high_charts/blob/master/spec/lazy_high_charts_spec.rb
describe LazyHighCharts::LayoutHelper do

  before { Daru::View.plotting_library = :highcharts }
  before(:each) do
    @placeholder = "placeholder"
    @chart = Daru::View::Plot.new
    @data = "data"
    @options = "options"
  end

  context "layout_helper" do
    it "should return a div with an id of high_chart object" do
      expect(@chart.chart.high_chart_iruby(
      	@placeholder,
      	@chart.chart)
      ).to match(/<div id="placeholder">/i)
    end

    it "should return a script" do
      expect(@chart.chart.high_chart_iruby(
      	@placeholder,
      	@chart.chart)
      ).to match(/script/i)
    end
  end

  context "high_chart_graph" do
    describe "ready function" do
      it "should be a javascript script" do
        expect(@chart.chart.high_chart_iruby(
        	@placeholder,
        	@chart.chart)
        ).to match(/<script type="text\/javascript">/i)
      end
    end

    describe "initialize HighChart" do
      it "should set variables `chart` `options`" do
        expect(@chart.chart.high_chart_iruby(
        	@placeholder,
        	@chart.chart)
        ).to match(/var\s+options\s+=/)
        expect(@chart.chart.high_chart_iruby(
        	@placeholder,
        	@chart.chart)
        ).to match(/window.chart_placeholder\s=/)
      end
      it "should set Chart data" do
        expect(@chart.chart.high_chart_iruby(
        	@placeholder,
        	@chart.chart)
        ).to match(/window\.chart_placeholder\s=\snew\sHighcharts.Chart/)
      end
      it "should set chart renderTo" do
        expect(@chart.chart.high_chart_iruby(
        	@placeholder,
        	@chart.chart)
        ).to match(/"renderTo": "placeholder"/)
      end
      it "should set Chart Stock" do
        expect(@chart.chart.high_stock_iruby(
        	@placeholder,
        	@chart.chart)
        ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.StockChart/)
      end
    end

    describe "HighChart Variable" do
      it "should underscore chart_ variable" do
        expect(@chart.chart.high_chart_iruby(
        	"place-holder",
        	@chart.chart)
        ).to match(/window.chart_place_holder\s=/)
        expect(@chart.chart.high_chart_iruby(
        	"PlaceHolder",
        	@chart.chart)
        ).to match(/window.chart_place_holder\s=/)
      end
    end
  end

  it "should take a block setting attributes" do
  	@hc = Daru::View::Plot.new
    @hc.chart.options[:rangeSelector] = {:selected => 1};
    @hc.chart.series(:type => "spline",
               :name => "Historias",
               :data => [0, 1, 2, 3, 5, 6, 0, 7]
    )
    expect(@hc.chart.options[:rangeSelector][:selected]).to eq(1)
    expect(@hc.chart.high_chart_iruby(
    	@placeholder,
    	@hc.chart)
    ).to match(/rangeSelector/)
    expect(@hc.chart.high_chart_iruby(@placeholder, @hc.chart)).to match(/xAxis/)
    expect(@hc.chart.high_chart_iruby(@placeholder, @hc.chart)).to match(/yAxis/)
    expect(@hc.chart.high_chart_iruby(@placeholder, @hc.chart)).to match(/series/)
  end

  it "should allow js code as attribute" do
    @hc = Daru::View::Plot.new
    @hc.chart.options[:foo] = "function () { alert('hello') }".js_code

    expect(@hc.chart.high_chart_iruby(
    	@placeholder,
    	@hc.chart)
    ).to match(/"foo": function \(\) { alert\('hello'\) }/)
  end

  it "should convert keys to proper format" do
  	@hc = Daru::View::Plot.new 
  	@hc.chart.options[:foo_bar] = {:bar_foo => "someattrib"}

    expect(@hc.chart.high_chart_iruby(@placeholder, @hc.chart)).to match(/fooBar/)
    expect(@hc.chart.high_chart_iruby(@placeholder, @hc.chart)).to match(/barFoo/)
  end

  it "should support js_code in Individual data label for each point" do
  	@hc = Daru::View::Plot.new
    @hc.chart.series(
      :data => [29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, {
        :dataLabels => {:enabled => true,
                      :align => 'left',
                      :x => 10,
                      :y => 4,
                      :style => {:fontWeight => 'bold'},
                      :formatter => "function() { return this.x; }".js_code
        },
        :y => 54.4}
      ]
    )
    expect(@hc.chart.high_chart_iruby(
    	@placeholder,
    	@hc.chart)
    ).to match(/"formatter": function\(\) {\ return this.x;\ }/)
  end
end
