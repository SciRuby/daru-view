require 'spec_helper.rb'

# refer lazy_high_charts_spec.rb here: 
#   https://github.com/michelson/lazy_high_charts/blob/master/spec/lazy_high_charts_spec.rb
describe LazyHighCharts::LayoutHelper do

  before { Daru::View.plotting_library = :highcharts }
  let(:placeholder) { "placeholder" }
  let(:opts) {{
      chart_class: 'stock',
      chart: {
        type: 'arearange'
      },
      modules: ['highcharts-more'],
      rangeSelector: {
        selected: 1
      },

      title: {
        text: 'AAPL Stock Price'
      }
  }}
  let(:series_dt) {[
    {
      name: 'AAPL Stock Price',
      data: [
              [1147651200000,67.79],
              [1147737600000,64.98],
              [1147824000000,65.26],

              [1149120000000,62.17],
              [1149206400000,61.66],
              [1149465600000,60.00],
              [1149552000000,59.72],

              [1157932800000,72.50],
              [1158019200000,72.63],
              [1158105600000,74.20],
              [1158192000000,74.17],
              [1158278400000,74.10],
              [1158537600000,73.89],

              [1170288000000,84.74],
              [1170374400000,84.75],

              [1174953600000,95.46],
              [1175040000000,93.24],
              [1175126400000,93.75],
              [1175212800000,92.91],

              [1180051200000,113.62],
              [1180396800000,114.35],
              [1180483200000,118.77],
              [1180569600000,121.19]
            ],
      marker: {
        enabled: true,
        radius: 3
      },
      shadow: true,
      tooltip: {
        valueDecimals: 2
      }
    }
  ]}
  let(:chart) { Daru::View::Plot.new(series_dt, opts) }

  let(:opts_map) {{
    chart_class: 'map',
    chart: {
      map: 'custom/europe',
      borderWidth: 1
    },
    modules: ['europe.js'],
    title: {
      text: 'Nordic countries'
    },
    subtitle: {
      text: 'Demo of drawing all areas in the map, only highlighting '\
            'partial data'
    },
    legend: {
      enabled: false
    }
  }}
  let(:df) { Daru::DataFrame.new(
    {
      data: [1, 1, 1, 1, 1]
    },
      index: ['is', 'no', 'se', 'dk', 'fi'],
      # index: [:one, :two, :three, :four, :five]
  )}
  let(:map) { Daru::View::Plot.new(df, opts_map) }

  context "layout_helper" do
    it "should return a div with an id of high_chart object" do
      expect(chart.chart.high_chart_iruby(
        "StockChart",
        placeholder,
        chart.chart)
      ).to match(/<div id="placeholder">/i)
      expect(map.chart.high_chart_iruby(
        "Map",
        placeholder,
        map.chart)
      ).to match(/<div id="placeholder">/i)
    end

    it "should return a script" do
      expect(chart.chart.high_chart_iruby(
        "StockChart",
        placeholder,
        chart.chart)
      ).to match(/script/i)
      expect(chart.chart.high_chart_iruby(
        "Map",
        placeholder,
        map.chart)
      ).to match(/script/i)
    end
  end

  context "high_chart_iruby" do
    describe "ready function" do
      it "should be a javascript script" do
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/<script type="text\/javascript">/i)
      end
      it "should be a javascript script" do
        expect(map.chart.high_chart_iruby(
          "Map",
          placeholder,
          map.chart)
        ).to match(/<script type="text\/javascript">/i)
      end
    end

    describe "initialize HighChart" do
      it "should set variables `chart` `options`" do
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/var\s+options\s+=/)
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/window.chart_placeholder\s=/)
      end
      it "should set Chart data" do
        expect(chart.chart.high_chart_iruby(
          "Chart",
          placeholder,
          chart.chart)
        ).to match(/window\.chart_placeholder\s=\snew\sHighcharts.Chart/)
      end
      it "should set chart renderTo" do
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/"renderTo": "placeholder"/)
      end
      it "should set Chart Stock" do
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.StockChart/)
      end
      it "should set Chart Map" do
        expect(chart.chart.high_chart_iruby(
          "Map",
          placeholder,
          chart.chart)
        ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.Map/)
      end
      it "should set correct options" do
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/series\": \[\{ \"name\": \"AAPL Stock Price\"/)
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/\"data\": \[ \[ 1147651200000,67.79 \]/)
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/\"title\": \{ \"text\": \"AAPL Stock Price\" \}/)
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/\"chart\": \{ \"type\": \"arearange\"/)
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/\"marker\": \{ \"enabled\": true/)
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/\"shadow\": true/)
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          placeholder,
          chart.chart)
        ).to match(/\"tooltip\": \{ \"valueDecimals\": 2/)
      end
    end

    describe "HighChart Variable" do
      it "should underscore chart_ variable" do
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          "place-holder",
          chart.chart)
        ).to match(/window.chart_place_holder\s=/)
        expect(chart.chart.high_chart_iruby(
          "StockChart",
          "PlaceHolder",
          chart.chart)
        ).to match(/window.chart_place_holder\s=/)
      end
    end
  end

  it "should take a block setting attributes" do
    @chart_class = "StockChart"
    @options = {
      chart_class: "stock",
      chart: {
        type: "spline"
      },
      xAxis: {
        categories: ['Apples', 'Oranges', 'Pears', 'Grapes', 'Bananas']
      },
      yAxis: {
        min: 0,
        title: {
          text: 'Total fruit consumption'
        }
      },
      rangeSelector: {
        selected: 1
      },
      name: "Historias",
    }
    @data = Daru::Vector.new([0, 1, 2, 3, 5])
    @hc = Daru::View::Plot.new(@data, @options)
    expect(@hc.options[:rangeSelector][:selected]).to eq(1)
    expect(@hc.chart.high_chart_iruby(
      @chart_class,
      placeholder,
      @hc.chart)
    ).to match(/rangeSelector/)
    expect(@hc.chart.high_chart_iruby(
      @chart_class,
      placeholder,
      @hc.chart)
    ).to match(/xAxis/)
    expect(@hc.chart.high_chart_iruby(
      @chart_class,
      placeholder,
      @hc.chart)
    ).to match(/yAxis/)
    expect(@hc.chart.high_chart_iruby(
      @chart_class,
      placeholder,
      @hc.chart)
    ).to match(/series/)
  end

  it "should allow js code as attribute" do
    @chart_class = "Chart"
    @options = {
      chart: {
        type: "bar"
      },
      positioner: "function () { return { x: 0, y: 250 }; }".js_code
    }
    @data = Daru::DataFrame.new(arr1: [1, 2, 3], arr2: [4, 5, 6])
    @hc = Daru::View::Plot.new(@data, @options)

    expect(@hc.chart.high_chart_iruby(
      @chart_class,
      placeholder,
      @hc.chart)
    ).to match(/"positioner": function \(\) { return { x: 0, y: 250 }; }/)
  end

  it "should convert keys to proper format" do
    @chart_class = "Chart"
    @options = {
      chart: {
        type: "bar"
      },
      plot_options: {
        bar: {
          data_labels: {
            enabled: true
          }
        }
      }
    }
    @data = Daru::Vector.new([0, 1, 2, 3, 9])
    @hc = Daru::View::Plot.new(@data, @options)

    expect(@hc.chart.high_chart_iruby(
      @chart_class,
      placeholder,
      @hc.chart)
    ).to match(/plotOptions/)
    expect(@hc.chart.high_chart_iruby(
      @chart_class,
      placeholder,
      @hc.chart)
    ).to match(/dataLabels/)
  end

  it "should support js_code in Individual data label for each point" do
    @hc = Daru::View::Plot.new
    @chart_class = "Chart"
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
      @chart_class,
      placeholder,
      @hc.chart)
    ).to match(/"formatter": function\(\) {\ return this.x;\ }/)
  end

  describe "#high_map" do
    it "should generate valid js code" do
      expect(map.chart.high_map(
        placeholder, map.chart)
      ).to match(/\"chart\": { \"map\": \"custom\/europe\"/)
      expect(map.chart.high_map(
        placeholder, map.chart)
      ).to match(/\"title\": { \"text\": \"Nordic countries\"/)
      expect(map.chart.high_map(
        placeholder, map.chart)
      ).to match(/\"legend\": { \"enabled\": false }/)
      # TODO: Broken due to being mapped as different series
      expect(map.chart.high_map(
        placeholder, map.chart)
      ).to match(/\"data\": \[ \[ \"is\",1 \]/)
    end
  end
end
