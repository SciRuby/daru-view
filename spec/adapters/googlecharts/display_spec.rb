require 'spec_helper.rb'

describe GoogleVisualr::Display do
  before { Daru::View.plotting_library = :googlecharts }
  let(:data) do
    [
      ['Year'],
      ['2013'],
    ]
  end
  let(:query_string) {'SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8'}
  let(:data_spreadsheet) {'https://docs.google.com/spreadsheets/d/1XWJLkAwch'\
              '5GXAt_7zOFDcg8Wm8Xv29_8PWuuW15qmAE/gviz/tq?gid=0&headers='\
              '1&tq=' << query_string}
  let (:plot_spreadsheet) {
    Daru::View::Plot.new(
      data_spreadsheet,
      {type: :column, width: 800}
    )
  }
  let(:user_options) {{chart_class: 'Chartwrapper'}}
  let(:data_table) {Daru::View::Table.new(data)}
  let(:area_chart_options) {{
      type: :area
    }}
  let(:column_chart_options) {{
      type: :column
    }}
  let(:area_chart_chart) {Daru::View::Plot.
    new(data_table.table, area_chart_options)}
  let(:column_chart_chart) {Daru::View::Plot.
  new(data_table.table, column_chart_options)}
  let(:area_chart_wrapper) {Daru::View::Plot.new(
    data_table.table,
    area_chart_options,
    user_options)
  }
  let(:table_chart_wrapper) {Daru::View::Table.new(
    data, {}, user_options)
  }

  describe "#to_html" do
    it "generates valid JS of the Area Chart" do
      js = area_chart_chart.chart.to_html("id")
      expect(js).to match(/<div id='id'>/i)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.AreaChart/i)
      expect(js).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid JS of the Column Chart" do
      js = column_chart_chart.chart.to_html("id")
      expect(js).to match(/<div id='id'>/i)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.ColumnChart/i)
      expect(js).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid JS of the google chart when data is imported " \
       "from google spreadsheet" do
      js = plot_spreadsheet.chart.to_html("id")
      expect(js).to match(/<div id='id'>/i)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.load\(/i)
      expect(js).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(js).to match(/gid=0&headers=1&tq=/i)
      expect(js).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(js).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
    it "generates valid JS of the google data_table" do
      js = data_table.table.to_html("id")
      expect(js).to match(/<div id='id'>/i)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
    end
    it "should generate the valid JS of chartwrapper" do
      js = area_chart_wrapper.chart.to_html('id')
      expect(js).to match(/<div id='id'>/i)
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'AreaChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
    it "should generate the valid JS of datatable chartwrapper" do
      js = table_chart_wrapper.table.to_html('id')
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback:\n draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
  end

  describe "#get_html_chart_wrapper" do
    it "should generate the valid JS of chartwrapper" do
      js = area_chart_wrapper.chart.get_html_chart_wrapper(data_table.table, 'id')
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'AreaChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
    it "should generate the valid JS of datatable chartwrapper" do
      js = table_chart_wrapper.table.get_html_chart_wrapper(data, 'id')
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback:\n draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
  end

  describe "#show_script" do
    it "generates valid script of the google chart without script tag" do
      chart_script = area_chart_chart.chart.show_script("id", script_tag: false)
      expect(chart_script).to match(/google.visualization.DataTable\(\);/i)
      expect(chart_script).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(chart_script).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(chart_script).to match(/google.visualization.AreaChart/i)
      expect(chart_script).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid script of the google chart with script tag" do
      chart_script = area_chart_chart.chart.show_script("id")
      expect(chart_script).to match(/<script type='text\/javascript'>/i)
      expect(chart_script).to match(/google.visualization.DataTable\(\);/i)
      expect(chart_script).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(chart_script).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(chart_script).to match(/google.visualization.AreaChart/i)
      expect(chart_script).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid script of the google chart when data is imported" \
       "from google spreadsheet without script tag" do
      chart_script = plot_spreadsheet.chart.show_script("id", script_tag: false)
      expect(chart_script).to match(/google.load\(/i)
      expect(chart_script).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(chart_script).to match(/gid=0&headers=1&tq=/i)
      expect(chart_script).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(chart_script).to match(/var data_table = response.getDataTable/i)
      expect(chart_script).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(chart_script).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
    it "generates valid script of the data_table without script tag" do
      table_script = data_table.table.show_script("id", script_tag: false)
      expect(table_script).to match(/google.visualization.DataTable\(\);/i)
      expect(table_script).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(table_script).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
    end
  end

  describe "#show_script_with_script_tag" do
    it "generates valid script of the google chart with script tag" do
      chart_script = area_chart_chart.chart.show_script_with_script_tag("id")
      expect(chart_script).to match(/<script type='text\/javascript'>/i)
      expect(chart_script).to match(/google.visualization.DataTable\(\);/i)
      expect(chart_script).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(chart_script).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(chart_script).to match(/google.visualization.AreaChart/i)
      expect(chart_script).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid script of the google chart when data is imported " \
       "from google spreadsheet with script tag" do
      chart_script = plot_spreadsheet.chart.show_script_with_script_tag("id")
      expect(chart_script).to match(/<script type='text\/javascript'>/i)
      expect(chart_script).to match(/google.load\(/i)
      expect(chart_script).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(chart_script).to match(/gid=0&headers=1&tq=/i)
      expect(chart_script).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(chart_script).to match(/var data_table = response.getDataTable/i)
      expect(chart_script).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(chart_script).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
    it "generates valid script of the data_table with script tag" do
      table_script = data_table.table.show_script_with_script_tag("id")
      expect(table_script).to match(/<script type='text\/javascript'>/i)
      expect(table_script).to match(/google.visualization.DataTable\(\);/i)
      expect(table_script).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(table_script).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
    end
  end

  describe "#get_html" do
    it "generates valid script of the google chart" do
      chart_script = area_chart_chart.chart.get_html("id")
      expect(chart_script).to match(/google.visualization.DataTable\(\);/i)
      expect(chart_script).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(chart_script).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(chart_script).to match(/google.visualization.AreaChart/i)
      expect(chart_script).to match(/chart.draw\(data_table, \{\}/i)
    end
  end

  describe "#get_html_spreadsheet" do
    it "draws valid JS of the chart when "\
       "data is imported from google spreadsheets" do
      chart_script = plot_spreadsheet.chart.get_html_spreadsheet(
        data_spreadsheet, 'id'
      )
      expect(chart_script).to match(/google.load\(/i)
      expect(chart_script).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(chart_script).to match(/gid=0&headers=1&tq=/i)
      expect(chart_script).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(chart_script).to match(/var data_table = response.getDataTable/i)
      expect(chart_script).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(chart_script).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
  end

  describe "#show_script_with_script_tag" do
    it "should generate valid script with script tag of chartwrapper" do
      js = area_chart_wrapper.chart.show_script_with_script_tag('id')
      expect(js).to match(/script/)
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'AreaChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
    it "should generate the valid JS of datatable chartwrapper" do
      js = table_chart_wrapper.table.show_script_with_script_tag('id')
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback:\n draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
  end
end
