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
    @opts = {
      chart: {
        type: 'bar'
      },
      title: {
        text: 'Bar chart'
      },
      yAxis: {
        min: 0,
        title: {
          text: 'Total consumption'
        }
      },
      legend: {
        reversed: true
      }
    }
    @data_vec1 = Daru::Vector.new([5, 3, 4])
    @data_vec2 = Daru::Vector.new([2, 2, 3])
    @data_vec3 = Daru::Vector.new([3,4,4])
    @data_df = Daru::DataFrame.new({John: @data_vec1, Jane: @data_vec2, Joe: @data_vec3})
    @hc = Daru::View::Plot.new(@data_df, @opts)
    @placeholder = "placeholder"
  end

  describe "#to_html" do
    before(:each) do
      @opts = {
          chart_class: 'stock',
          chart: {
            type: 'arearange'
          },
          rangeSelector: {
              selected: 1
          },

          title: {
              text: 'AAPL Stock Price'
          }
      }
      @series_dt = [
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
                  [1180569600000,121.19],
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
      ]
      @chart = Daru::View::Plot.new
      @chart.chart.options = @opts;
      @chart.chart.series_data = @series_dt
  	end
    it "should plot Highstock when chart_class is set to stock" do
      @hc.options[:chart_class] = "STock";
      expect(@hc.chart.to_html(
        @placeholder)
      ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.StockChart/)
    end
    it "should plot HighChart otherwise" do
      expect(@hc.chart.to_html(
        @placeholder)
      ).to match(/window\.chart_placeholder\s+=\s+new\s+Highcharts.Chart/)
    end
    it "should return a div with an id of high_chart object" do
      expect(@chart.chart.to_html(@placeholder)).to match(/<div id="placeholder">/)
      expect(@hc.chart.to_html(@placeholder)).to match(/<div id="placeholder">/)
    end
    it "should return a script" do
      expect(@chart.chart.to_html(@placeholder)).to match(/script/)
      expect(@hc.chart.to_html(@placeholder)).to match(/script/)
    end
    it "should set variables `chart` `options`" do
      expect(@chart.chart.to_html(@placeholder)).to match(/var\s+options\s+=/)
      expect(@chart.chart.to_html(@placeholder)).to match(/window.chart_placeholder/)
      expect(@hc.chart.to_html(@placeholder)).to match(/var\s+options\s+=/)
      expect(@hc.chart.to_html(@placeholder)).to match(/window.chart_placeholder/)
    end
    it "should take a block setting attributes" do
      expect(@chart.chart.options[:rangeSelector][:selected]).to eq(1)
      expect(@chart.chart.to_html(@placeholder)).to match(/rangeSelector/)
      expect(@chart.chart.to_html(
        @placeholder)
      ).to match(/series\": \[\{ \"name\": \"AAPL Stock Price\"/)
      expect(@chart.chart.to_html(
        @placeholder)
      ).to match(/\"data\": \[ \[ 1147651200000,67.79 \]/)
      expect(@chart.chart.to_html(
        @placeholder)
      ).to match(/\"title\": \{ \"text\": \"AAPL Stock Price\" \}/)
      expect(@chart.chart.to_html(
        @placeholder)
      ).to match(/\"chart\": \{ \"type\": \"arearange\"/)
      expect(@chart.chart.to_html(
        @placeholder)
      ).to match(/\"marker\": \{ \"enabled\": true/)
      expect(@chart.chart.to_html(@placeholder)).to match(/\"shadow\": true/)
      expect(@chart.chart.to_html(
        @placeholder)
      ).to match(/\"tooltip\": \{ \"valueDecimals\": 2/)
      expect(@hc.chart.to_html(
        @placeholder)
      ).to match(/\"chart\": \{ \"type\": \"bar\"/)
      expect(@hc.chart.to_html(
        @placeholder)
      ).to match(/\"data\": \[ \[ 5,2,3 \],\[ 3,2,4 \],\[ 4,3,4 \] \]/)
      expect(@hc.chart.to_html(
        @placeholder)
      ).to match(/\"title\": \{ \"text\": \"Bar chart\" \}/)
      expect(@hc.chart.to_html(
        @placeholder)
      ).to match(/\"legend\": \{ \"reversed\": true \}/)
      expect(@hc.chart.to_html(
        @placeholder)
      ).to match(/\"yAxis\": \{ \"min\": 0/)
    end
  end

  describe "#to_html_iruby" do
    it "should plot Highstock when chart_class is set to stock" do
      @hc.options[:chart_class] = "SToCk";
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
    it "should return StockChart class when chart_class is set to stock" do
      @hc.options[:chart_class] = "SToCk";
      expect(@hc.chart.extract_chart_class).to eq 'StockChart'
    end
    it "should return Chart class when chart_class is not set" do
      expect(@hc.chart.extract_chart_class).to eq 'Chart'
    end
    it "should raise error when wrong input is given" do
      @hc.options[:chart_class] = "Daru"
      expect{@hc.chart.extract_chart_class}.to raise_error(
        'chart_class must be selected as either chart, stock or map'
      )
    end
  end

  describe "#chart_hash_must_be_present" do
    it "should check the presence of chart hash in options" do
      @hc.chart.chart_hash_must_be_present
      expect(@hc.options[:chart]).to eq :type=>"bar"
    end
  end
end
