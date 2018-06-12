require 'spec_helper.rb'

describe GoogleVisualr::BaseChart do
  before { Daru::View.plotting_library = :googlecharts }
  before(:each) do
    @query_string = 'SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8'
    @data_spreadsheet = 'https://docs.google.com/spreadsheets/d/1XWJLkAwch'\
              '5GXAt_7zOFDcg8Wm8Xv29_8PWuuW15qmAE/gviz/tq?gid=0&headers=1&tq='
    @data_spreadsheet << @query_string
    @plot_spreadsheet = Daru::View::Plot.new(
                          @data_spreadsheet,
                          {type: :column, width: 800}
                        )
    @data = [
              ['Year', 'Sales', 'Expenses'],
              ['2013',  1000,      400],
              ['2014',  1170,      460],
              ['2015',  660,       1120],
              ['2016',  1030,      540]
            ]
    @area_chart = Daru::View::Plot.new(
      @data,
      {type: :area, width: 800, view: {columns: [0, 1]}},
      class_chart: 'ChartWrapper'
    )
    @area_chart_spreadsheet = Daru::View::Plot.new(
      @data_spreadsheet,
      {type: :area},
      class_chart: 'ChartWrapper'
    )
  end
  let (:plot_spreadsheet_charteditor) {
    Daru::View::Plot.new(
      @data_spreadsheet, {width: 800, view: {columns: [0, 1]}}, class_chart: 'Charteditor'
    )
  }
  let(:plot_charteditor) {Daru::View::Plot.new(@data, {}, class_chart: 'Charteditor')}

  describe "#query_response_function_name" do
    it "should generate unique function name to handle query response" do
      func = @plot_spreadsheet.chart.query_response_function_name('i-d')
      expect(func).to eq('handleQueryResponse_i_d')
    end
  end

  describe "#append_data" do
    it "should return option dataSourceUrl if data is URL" do
      js = @area_chart_spreadsheet.chart.append_data(@data_spreadsheet)
      expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
    end
    it "should return option dataTable otherwise" do
      js = @area_chart.chart.append_data(@data)
      expect(js).to match(/dataTable: data_table/)
    end
  end

  describe "#extract_option_view" do
    it "should return value of view option if view option is provided" do
      js = @area_chart.chart.extract_option_view
      expect(js).to eq('{columns: [0,1]}')
    end
    it "should return '' if view option is not provided" do
      js = @area_chart_spreadsheet.chart.extract_option_view
      expect(js).to eq('\'\'')
    end
  end

  describe "#draw_wrapper" do
    it "should draw the chartwrapper only when class_chart is"\
       " set to Chartwrapper" do
      js = @area_chart.chart.draw_wrapper('id')
      expect(js).to match(/wrapper_id.draw\(\);/)
    end
    it "should draw the chartwrapper only when class_chart is"\
       " set to Chartwrapper" do
      js = plot_charteditor.chart.draw_wrapper('id')
      expect(js).to match(/wrapper_id.draw\(\);/)
      expect(js).to match(/new google.visualization.ChartEditor()/)
      expect(js).to match(/google.visualization.events.addListener/)
      expect(js).to match(/chartEditor_id, 'ok', saveChart_id/)
    end
  end

  describe "#extract_chart_wrapper_options" do
    it "should return correct options of chartwrapper" do
      js = plot_charteditor.chart.extract_chart_wrapper_options(@data, 'id')
      expect(js).to match(/chartType: 'LineChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: \{\}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
    it "should return correct options of chartwrapper when data is URL" do
      js = plot_spreadsheet_charteditor.chart.extract_chart_wrapper_options(
        @data_spreadsheet, 'id'
      )
      expect(js).to match(/chartType: 'LineChart'/)
      expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
      expect(js).to match(/options: {width: 800/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: {columns: \[0,1\]}/)
    end
  end

  describe "#save_chart_function_name" do
    it "should generate unique function name to save the chart" do
      func = plot_spreadsheet_charteditor.chart.save_chart_function_name('i-d')
      expect(func).to eq('saveChart_i_d')
    end
  end

  describe "#to_js_spreadsheet" do
    it "generates valid JS of the chart when "\
       "data is imported from google spreadsheets" do
      js = @plot_spreadsheet.chart.to_js_spreadsheet(@data_spreadsheet, 'id')
      expect(js).to match(/<script type='text\/javascript'>/i)
      expect(js).to match(/google.load\(/i)
      expect(js).to match(/google.visualization.Query\('https:\/\/docs.google\
.com\/spreadsheets\/d\/1XWJLkAwch5GXAt_7zOFDcg8Wm8Xv29_8PWuuW15qmAE\/gviz\/tq\
\?gid=0&headers=1&tq=SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8'\)/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(js).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
  end

  describe "#to_js_chart_wrapper" do
    it "draws valid JS of the ChartWrapper when data is URL of the spreadsheet" do
      js = @area_chart_spreadsheet.chart.to_js_chart_wrapper(
        @data_spreadsheet,
        'id'
      )
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'AreaChart'/)
      expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
    end
  end

  describe "#load_js_chart_editor" do
    it "loads valid packages" do
      js = plot_charteditor.chart.load_js_chart_editor('id')
      expect(js).to match(/google.load\('visualization', '1.0',/i)
      expect(js).to match(/\{packages: \['charteditor'\], callback:/i)
      expect(js).to match(/draw_id\}\)/i)
    end
  end

  describe "#draw_js_chart_wrapper" do
    it "draws valid JS of the ChartWrapper" do
      js = @area_chart.chart.draw_js_chart_wrapper(@data, 'id')
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'AreaChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {width: 800/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: {columns: \[0,1\]}/)
    end
  end

  describe "#draw_js_chart_editor" do
    it "draws valid JS of the ChartEditor" do
      js = plot_charteditor.chart.draw_js_chart_editor(@data, 'id')
      expect(js).to match(/var chartEditor_id = null/)
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'LineChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: \{\}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/chartEditor_id.getChartWrapper\(\).draw\(/)
      expect(js).to match(/chartEditor_id.openDialog\(wrapper_id, {}\)/)
      expect(js).to match(/containerId: 'id'/)
    end
    it "draws valid JS of the ChartEditor when URL of spreadsheet is provided" do
      js = plot_spreadsheet_charteditor.chart.draw_js_chart_editor(@data_spreadsheet, 'id')
      expect(js).to match(/var chartEditor_id = null/)
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'LineChart'/)
      expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
      expect(js).to match(/options: {width: 800/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/chartEditor_id.getChartWrapper\(\).draw\(/)
      expect(js).to match(/chartEditor_id.openDialog\(wrapper_id, {}\)/)
      expect(js).to match(/containerId: 'id'/)
    end
  end

  describe "#draw_js_spreadsheet" do
    it "draws valid JS of the chart when "\
       "data is imported from google spreadsheets" do
      js = @plot_spreadsheet.chart.draw_js_spreadsheet(@data_spreadsheet, 'id')
      expect(js).to match(/google.visualization.Query\('https:\/\/docs.google\
.com\/spreadsheets\/d\/1XWJLkAwch5GXAt_7zOFDcg8Wm8Xv29_8PWuuW15qmAE\/gviz\/tq\?\
gid=0&headers=1&tq=SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8'\)/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(js).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
  end
end