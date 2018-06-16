require 'spec_helper.rb'

# some specs from lazy_high_charts specs
describe Daru::View::Plot, 'plotting with highcharts' do
  before { Daru::View.plotting_library = :highcharts }
  before(:each) do
    @placeholder = "placeholder"
    @html_options = {:class => "stylin"}
    @data = [[1, 15], [2, 30], [4, 40]]
    @data_vec1 = Daru::Vector.new([3,6,8,9,20])
    @data_vec2 = Daru::Vector.new([9,4,1,3,12])
    @data_df = Daru::DataFrame.new(rows: @data_vec1, values: @data_vec2)
    @options_bar = {
      chart: {
        type: 'bar',
      },
      title: {
        text: 'Demo Bar Chart'
      },
      plotOptions: {
        bar: {
          dataLabels: {
            enabled: true
          }
        }
      }
    }
    @options_line = {
      chart: {
        type: 'line'
      },
      title: {
        text: 'Demo line Chart'
      },
      plotOptions: {
        line: {
          dataLabels: {
            enabled: true
          },
          enableMouseTracking: false
        }
      }
    }
    @options_column = {
      chart: {
        type: 'column'
      },
      title: {
        text: 'Demo Column Chart'
      }
    }
    @series_dt = [{
        name: 'Tokyo',
        data: [49.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4]
      }, {
        name: 'New York',
        data: [83.6, 78.8, 98.5, 93.4, 106.0, 84.5, 105.0, 104.3, 91.2, 83.5, 106.6, 92.3]
    }]
    @chart_line = Daru::View::Plot.new(@data_vec1, @options_line)
    @chart_bar = Daru::View::Plot.new(@data_df, @options_bar)
    @chart_multiple_series = Daru::View::Plot.new(@series_dt, @options_bar)
    @chart_column = Daru::View::Plot.new
    @chart_column.chart.options = @options_column
    @chart_column.chart.series_data = @data
  end

  describe "initialization" do
    it "shouldn't generate a nil placeholder" do
      expect(Daru::View::Plot.new.chart.placeholder).not_to be_nil
    end

    let(:plt) { Daru::View::Plot.new }
    before { plt.chart.placeholder = @placeholder }
    it "should take an optional 'placeholder' argument" do
      expect(plt.chart.placeholder).to eq(@placeholder)
      expect(Daru::View::Plot.new.chart.placeholder).not_to eq(@placeholder)
    end

    it "should generate different placeholders for different charts" do
      a_different_placeholder = Daru::View::Plot.new.chart.placeholder
      expect(Daru::View::Plot.new.chart.placeholder).not_to eq(a_different_placeholder)
    end

    it "should able take an optional html_options argument (defaulting to 300px height)" do
      expect(Daru::View::Plot.new.chart.html_options).to eq({})
    end

    before { plt.chart.html_options = @html_options }
    it "should able take an optional html_options argument (defaulting to 300px height)" do
      expect(plt.chart.html_options).to eq(@html_options)
    end

    it "should set options by default" do
      expect(Daru::View::Plot.new.chart.options).to eq({
        :title => {:text => nil},
        :legend => {:layout => "vertical", :style => {}},
        :xAxis => {},
        :yAxis => {:title => {:text => nil}, :labels => {}},
        :tooltip => {:enabled => true},
        :credits => {:enabled => false},
        :plotOptions => {:areaspline => {}},
        :chart => {:defaultSeriesType => "line", :renderTo => nil},
        :subtitle => {}
      })
  end

    it "should set data empty by default" do
      expect(Daru::View::Plot.new.chart.series_data).to eq(
        [{:type=>nil, :name=>nil, :data=>[]}])
    end

    let(:graph) { Daru::View::Plot.new }
    it "should take a block setting attributes" do
      graph.chart.tap do |f|
        f.series_data = @data
        f.options = @options
      end
      expect(graph.chart.series_data).to eq(@data)
      expect(graph.chart.options).to eq(@options)
    end

    it "should take a block setting attributes" do
      # Didn't understand why it fails :
      # 1. when we do graph.chart do |f| ..
      # 2. when we do graph.chart {|f| ..}
      graph_chart = graph.chart.tap do |f|
        f.options[:legend][:layout] = "horizontal"
      end
      expect(graph_chart.options[:legend][:layout]).to eq("horizontal")
    end

    it "should take a block setting attributes" do
      graph_chart = graph.chart.tap do |f|
        f.options[:range_selector] = {}
        f.options[:range_selector][:selected] = 1
      end
      expect(graph_chart.options[:range_selector][:selected]).to eq(1)
    end

    it "should change a block data without overriding options" do
      graph = Daru::View::Plot.new.chart.tap do |f|
        f.series(:name => 'John', :data => [3, 20])
        f.series(:name => 'Jane', :data => [1, 3])
        # without overriding
        f.options[:chart][:defaultSeriesType] = "area"
        f.options[:chart][:inverted] = true
        f.options[:legend][:layout] = "horizontal"
        f.options[:xAxis][:categories] = ["uno", "dos", "tres", "cuatro"]
      end
      # {type: nil, :name => nil, :data => []} series is added during
      # the initialzation of chart. User can remove it using this line:
      # graph.delete({type: nil, :name => nil, :data => []})
      expect(graph.series_data).to eq([
        {type: nil, :name => nil, :data => []},
        {:name => "John", :data => [3, 20]},
        {:name => "Jane", :data => [1, 3]}
      ])
      expect(graph.options[:legend][:layout]).to eq("horizontal")
      expect(graph.options[:xAxis][:categories]).to eq(["uno", "dos", "tres", "cuatro"])
      expect(graph.options[:chart][:defaultSeriesType]).to eq("area")
      expect(graph.options[:chart][:inverted]).to eq(true)
    end

    it "should change a block data with overriding entire options" do
      graph = Daru::View::Plot.new.chart.tap do |f|
        f.series(:name => 'John', :data => [3, 20])
        f.series(:name => 'Jane', :data => [1, 3])
        f.title({:text => nil})
        # without overriding
        f.xAxis(:categories => ["uno", "dos", "tres", "cuatro"], :labels => {:rotation => -45, :align => 'right'})
        f.chart({:defaultSeriesType => "spline", :renderTo => "myRenderArea", :inverted => true})
      end
      expect(graph.options[:xAxis][:categories]).to eq(["uno", "dos", "tres", "cuatro"])
      expect(graph.options[:xAxis][:labels][:rotation]).to eq(-45)
      expect(graph.options[:xAxis][:labels][:align]).to eq("right")
      expect(graph.options[:chart][:defaultSeriesType]).to eq("spline")
      expect(graph.options[:chart][:renderTo]).to eq("myRenderArea")
      expect(graph.options[:chart][:inverted]).to eq(true)
    end

    it "should have subtitles" do
      graph = Daru::View::Plot.new.chart.tap do |f|
        f.series(:name => 'John', :data => [3, 20])
        f.series(:name => 'Jane', :data => [1, 3])
        f.title({:text => nil})
        # without overriding
        f.x_axis(:categories => ["uno", "dos", "tres", "cuatro"], :labels => {:rotation => -45, :align => 'right'})
        f.chart({:defaultSeriesType => "spline", :renderTo => "myRenderArea", :inverted => true})
        f.subtitle({:text => "Bar"})
      end
      expect(graph.options[:subtitle][:text]).to eq("Bar")
    end

    it 'should override entire option by default when resetting it again' do
      graph = Daru::View::Plot.new.chart.tap do |f|
        f.xAxis(categories: [3, 5, 7])
        f.xAxis(title: {text: 'x title'})
      end
      expect(graph.options[:xAxis][:categories]).to eq(nil)
      expect(graph.options[:xAxis][:title][:text]).to eq('x title')
    end

    it 'should allow to build options step by step without overriding previously set values' do
      graph = Daru::View::Plot.new.chart.tap do |f|
        f.xAxis!(categories: [3, 5, 7])
        f.xAxis!(title: {text: 'x title'})
      end
      expect(graph.options[:xAxis][:categories]).to eq([3, 5, 7])
      expect(graph.options[:xAxis][:title][:text]).to eq('x title')
    end

    it 'should merge options and data into a full options hash' do
      graph = Daru::View::Plot.new.chart.tap do |f|
        f.series(name: 'John', data: [29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4])
        f.series(name: 'Jane', data: [140.02, 41.63, 66.72, 113.21, 107.98, 105.71, 28.59, 114.23, 5.56, 93.71, 137.35, 93.16])
        f.title({text: 'Example Data'})
        f.xAxis(categories: %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec), labels: {rotation: -45, align: 'right'})
        f.options[:tooltip][:formatter] = "function(){ return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.percentage, 2) +' %'; }"
      end

      json = graph.full_options
      expect(json).to match /\"series\"/
      expect(json).to match /\"title\"/
      expect(json).to match /\"tooltip\": { \"enabled\": true,\"formatter\"/
      expect(json).to match /\"data\": \[ 29.9,71.5,106.4,129.2,144.0,176.0,135.6,148.5,216.4,194.1,95.6,54.4 \]/
    end

  end

  describe "#init_script" do
    it "generates valid initial script" do
      js = @chart_bar.init_script
      expect(js).to match(/BEGIN highstock.js/i)
      expect(js).to match(/Highstock JS/i)
      expect(js).to match(/END highstock.js/i)
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

  # called from #div in plot.rb as @chart_line.div
  describe "#generate_body" do
    context "when Line Chart is drawn" do
      it "should generate valid JS of the Line Chart" do
        js = @chart_line.adapter.generate_body(@chart_line.chart)
        expect(js).to match(/script/)
        expect(js).to match(/Highcharts.Chart\(options\)/)
        expect(js).to match(/window.chart_/)
      end
      it "should set the correct options" do
        js = @chart_line.adapter.generate_body(@chart_line.chart)
        expect(js).to match(/\"chart\": { \"type\": \"line\"/)
        expect(js).to match(/\"title\": { \"text\": \"Demo line Chart\" }/)
        expect(js).to match(
          /\"plotOptions\": { \"line\": { \"dataLabels\": { \"enabled\": true }/
        )
      end
      it "should set correct data" do
        js = @chart_line.adapter.generate_body(@chart_line.chart)
        expect(js).to match(/series/)
        expect(js).to match(/\"type\": null/)
        expect(js).to match(/\"name\": null/)
        expect(js).to match(/\"data\": \[ 3,6,8,9,20 \]/)
      end
    end
    context "when Bar Chart is drawn" do
      it "should generate valid JS of the Bar Chart" do
        js = @chart_bar.adapter.generate_body(@chart_bar.chart)
        expect(js).to match(/script/)
        expect(js).to match(/Highcharts.Chart\(options\)/)
        expect(js).to match(/window.chart_/)
      end
      it "should set the correct options" do
        js = @chart_bar.adapter.generate_body(@chart_bar.chart)
        expect(js).to match(/\"chart\": { \"type\": \"bar\"/)
        expect(js).to match(/\"title\": { \"text\": \"Demo Bar Chart\" }/)
        expect(js).to match(
          /\"plotOptions\": { \"bar\": { \"dataLabels\": { \"enabled\": true }/
        )
      end
      it "should set correct data" do
        js = @chart_bar.adapter.generate_body(@chart_bar.chart)
        expect(js).to match(/series/)
        expect(js).to match(/\"type\": null/)
        expect(js).to match(/\"name\": null/)
        expect(js).to match(
          /\"data\": \[ \[ 3,9 \],\[ 6,4 \],\[ 8,1 \],\[ 9,3 \],\[ 20,12 \] \]/
        )
      end
    end
    context "when Column Chart is drawn" do
      it "should generate valid JS of the Column Chart" do
        js = @chart_column.adapter.generate_body(@chart_column.chart)
        expect(js).to match(/script/)
        expect(js).to match(/Highcharts.Chart\(options\)/)
        expect(js).to match(/window.chart_/)
      end
      it "should set the correct options" do
        js = @chart_column.adapter.generate_body(@chart_column.chart)
        expect(js).to match(/\"chart\": { \"type\": \"column\"/)
        expect(js).to match(/\"title\": { \"text\": \"Demo Column Chart\" }/)
      end
      it "should set correct data" do
        js = @chart_column.adapter.generate_body(@chart_column.chart)
        expect(js).to match(/series": \[\[ 1,15 \],\[ 2,30 \],\[ 4,40 \]\]/)
      end
    end
    context "when multiple series is used as data" do
      it "should generate valid JS of the Chart" do
        js = @chart_multiple_series.adapter.generate_body(
          @chart_multiple_series.chart
        )
        expect(js).to match(/script/)
        expect(js).to match(/Highcharts.Chart\(options\)/)
        expect(js).to match(/window.chart_/)
      end
      it "should set the correct options" do
        js = @chart_multiple_series.adapter.generate_body(
          @chart_multiple_series.chart
        )
        expect(js).to match(/\"chart\": { \"type\": \"bar\"/)
        expect(js).to match(/\"title\": { \"text\": \"Demo Bar Chart\" }/)
      end
      it "should set correct data" do
        js = @chart_multiple_series.adapter.generate_body(
          @chart_multiple_series.chart
        )
        # indicates series contains array of hashes
        expect(js).to match(/series": \[\{/)
      end
    end
  end

  describe "#generate_html" do
    it "should generate valid HTML of the Line Chart" do
      html = @chart_line.adapter.generate_html(@chart_line.chart)
      expect(html).to match(/html/)
      expect(html).to match(/Chart/)
      expect(html).to match(/BEGIN highstock.js/i)
      expect(html).to match(/END highstock.js/i)
      expect(html).to match(/BEGIN modules\/exporting.js/i)
      expect(html).to match(/END modules\/exporting.js/i)
      expect(html).to match(/BEGIN highcharts-3d.js/i)
      expect(html).to match(/END highcharts-3d.js/i)
      expect(html).to match(/BEGIN modules\/data.js/i)
      expect(html).to match(/END modules\/data.js/i)
      expect(html).to match(/script/)
      expect(html).to match(/Highcharts.Chart\(options\)/)
      expect(html).to match(/\"chart\": { \"type\": \"line\"/)
      expect(html).to match(/\"title\": { \"text\": \"Demo line Chart\" }/)
      expect(html).to match(/\"data\": \[ 3,6,8,9,20 \]/)
    end
    it "should generate valid HTML of the Bar Chart" do
      html = @chart_bar.adapter.generate_html(@chart_bar.chart)
      expect(html).to match(/html/)
      expect(html).to match(/Chart/)
      expect(html).to match(/BEGIN highstock.js/i)
      expect(html).to match(/END highstock.js/i)
      expect(html).to match(/BEGIN modules\/exporting.js/i)
      expect(html).to match(/END modules\/exporting.js/i)
      expect(html).to match(/BEGIN highcharts-3d.js/i)
      expect(html).to match(/END highcharts-3d.js/i)
      expect(html).to match(/BEGIN modules\/data.js/i)
      expect(html).to match(/END modules\/data.js/i)
      expect(html).to match(/script/)
      expect(html).to match(/Highcharts.Chart\(options\)/)
      expect(html).to match(/\"chart\": { \"type\": \"bar\"/)
      expect(html).to match(/\"title\": { \"text\": \"Demo Bar Chart\" }/)
      expect(html).to match(
        /\"data\": \[ \[ 3,9 \],\[ 6,4 \],\[ 8,1 \],\[ 9,3 \],\[ 20,12 \] \]/
      )
    end
    it "should generate valid HTML of the Column Chart" do
      html = @chart_column.adapter.generate_html(@chart_column.chart)
      expect(html).to match(/html/)
      expect(html).to match(/Chart/)
      expect(html).to match(/BEGIN highstock.js/i)
      expect(html).to match(/END highstock.js/i)
      expect(html).to match(/BEGIN modules\/exporting.js/i)
      expect(html).to match(/END modules\/exporting.js/i)
      expect(html).to match(/BEGIN highcharts-3d.js/i)
      expect(html).to match(/END highcharts-3d.js/i)
      expect(html).to match(/BEGIN modules\/data.js/i)
      expect(html).to match(/END modules\/data.js/i)
      expect(html).to match(/script/)
      expect(html).to match(/Highcharts.Chart\(options\)/)
      expect(html).to match(/\"chart\": { \"type\": \"column\"/)
      expect(html).to match(/\"title\": { \"text\": \"Demo Column Chart\" }/)
      expect(html).to match(/series": \[\[ 1,15 \],\[ 2,30 \],\[ 4,40 \]\]/)
    end
  end

  describe "#export_html_file" do
    it "should write valid html code of the Line Chart to the file" do
      @chart_line.export_html_file('./plot.html')
      path = File.expand_path('../../plot.html', __dir__)
      html = File.read(path)
      expect(html).to match(/html/)
      expect(html).to match(/Chart/)
      expect(html).to match(/BEGIN highstock.js/i)
      expect(html).to match(/END highstock.js/i)
      expect(html).to match(/script/)
      expect(html).to match(/Highcharts.Chart\(options\)/)
      expect(html).to match(/\"chart\": { \"type\": \"line\"/)
      expect(html).to match(/\"title\": { \"text\": \"Demo line Chart\" }/)
    end
    it "should write valid html code of the Bar Chart to the file" do
      @chart_bar.export_html_file('./plot.html')
      path = File.expand_path('../../plot.html', __dir__)
      html = File.read(path)
      expect(html).to match(/html/)
      expect(html).to match(/Chart/)
      expect(html).to match(/BEGIN highstock.js/i)
      expect(html).to match(/END highstock.js/i)
      expect(html).to match(/script/)
      expect(html).to match(/Highcharts.Chart\(options\)/)
      expect(html).to match(/\"chart\": { \"type\": \"bar\"/)
      expect(html).to match(/\"title\": { \"text\": \"Demo Bar Chart\" }/)
      expect(html).to match(
        /\"data\": \[ \[ 3,9 \],\[ 6,4 \],\[ 8,1 \],\[ 9,3 \],\[ 20,12 \] \]/
      )
    end
    it "should write valid html code of the Column Chart to the file" do
      @chart_column.export_html_file('./plot.html')
      path = File.expand_path('../../plot.html', __dir__)
      html = File.read(path)
      expect(html).to match(/html/)
      expect(html).to match(/Chart/)
      expect(html).to match(/BEGIN highstock.js/i)
      expect(html).to match(/END highstock.js/i)
      expect(html).to match(/script/)
      expect(html).to match(/Highcharts.Chart\(options\)/)
      expect(html).to match(/\"chart\": { \"type\": \"column\"/)
      expect(html).to match(/\"title\": { \"text\": \"Demo Column Chart\" }/)
      expect(html).to match(/series": \[\[ 1,15 \],\[ 2,30 \],\[ 4,40 \]\]/)
    end
  end
end
