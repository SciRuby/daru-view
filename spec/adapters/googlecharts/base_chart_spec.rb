require 'spec_helper.rb'

describe GoogleVisualr::BaseChart do
  before { Daru::View.plotting_library = :googlecharts }
  let(:query_string) {'SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8'}
  let(:data_spreadsheet) {'https://docs.google.com/spreadsheets/d/1XWJLkAwch'\
              '5GXAt_7zOFDcg8Wm8Xv29_8PWuuW15qmAE/gviz/tq?gid=0&headers='\
              '1&tq=' << query_string}
  let(:plot_spreadsheet) {
    Daru::View::Plot.new(
      data_spreadsheet,
      {type: :column, width: 800}
    )
  }
  let(:data_array) do
    [
      ['Year'],
      ['2013'],
    ]
  end
  let(:column_chart) {
    Daru::View::Plot.new(data_array, type: :column)
  }
  let(:data) {
    [
      ['Year', 'Sales', 'Expenses'],
      ['2013',  1000,      400],
      ['2014',  1170,      460],
      ['2015',  660,       1120],
      ['2016',  1030,      540]
    ]
  }
  let(:area_chart) {
    Daru::View::Plot.new(
      data,
      {type: :area, width: 800, view: {columns: [0, 1]}},
      chart_class: 'ChartWrapper'
    )
  }
  let(:area_chart_spreadsheet) {
    Daru::View::Plot.new(
      data_spreadsheet,
      {type: :area},
      chart_class: 'ChartWrapper'
    )
  }

  describe "#extract_option_view" do
    it "should return value of view option if view option is provided" do
      js = area_chart.chart.extract_option_view
      expect(js).to eq('{columns: [0,1]}')
    end
    it "should return '' if view option is not provided" do
      js = area_chart_spreadsheet.chart.extract_option_view
      expect(js).to eq('\'\'')
    end
  end

  describe "#draw_js_chart_wrapper" do
    it "draws valid JS of the ChartWrapper" do
      js = area_chart.chart.draw_js_chart_wrapper(data, 'id')
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'AreaChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {width: 800/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: {columns: \[0,1\]}/)
    end
  end

  describe "#draw_js_spreadsheet" do
    it "draws valid JS of the chart when "\
       "data is imported from google spreadsheets" do
      js = plot_spreadsheet.chart.draw_js_spreadsheet(data_spreadsheet, 'id')
      expect(js).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(js).to match(/gid=0&headers=1&tq=/i)
      expect(js).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(js).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
  end

  describe "#draw_chart_js" do
    subject(:js) { column_chart.chart.draw_chart_js('id') }
    it "adds correct data" do
      expect(js).to match(/var chart = null;/)
      expect(js).to match(
        /data_table.addColumn\({"type":"string","label":"Year"}\)/
      )
      expect(js).to match(/data_table.addRow\(\[{v: "2013"}\]\)/)
    end
    it "adds correct listener" do
      column_chart.chart.add_listener('ready', "alert('hi');")
      expect(js).to match(
        /google.visualization.events.addListener\(chart, 'ready', function \(e\) {/
      )
      expect(js).to match(/alert\('hi'\);/)
    end
    it "generates the valid chart script" do
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ColumnChart/)
      expect(js).to match(/chart.draw\(data_table, {}\)/)
    end
  end
end
