require 'spec_helper.rb'

describe GoogleVisualr::DataTable do
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
  let (:table_spreadsheet) {
    Daru::View::Table.new(
      data_spreadsheet, {width: 800},
    )
  }
  let(:data_table) {Daru::View::Table.new(data)}
  let (:table_spreadsheet_chartwrapper) {
    Daru::View::Table.new(
      data_spreadsheet, {width: 800, view: {columns: [0, 1]}}, class_chart: 'ChartWrapper'
    )
  }
  let(:table_chartwrapper) {Daru::View::Table.new(data, {}, class_chart: 'ChartWrapper')}

  describe "#to_js_full_script" do
  	it "generates valid JS of the table" do
  	  js = data_table.table.to_js_full_script('id')
      expect(js).to match(/<script type='text\/javascript'>/i)
      expect(js).to match(/google.load\(/i)
      expect(js).to match(/google.visualization.DataTable\(\)/i)
  	  expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.Table/i)
      expect(js).to match(/table.draw\(data_table, \{\}/i)
  	end
  end

  describe "#to_js_chart_wrapper" do
    it "draws valid JS of the ChartWrapper when data is URL of the spreadsheet" do
      js = table_spreadsheet_chartwrapper.table.to_js_full_script_chart_wrapper(
        data_spreadsheet,
        'id'
      )
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback:\n draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
      expect(js).to match(/options: {width: 800/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: {columns: \[0,1\]}/)
    end
  end

  describe "#append_data" do
    it "should return option dataSourceUrl if data is URL" do
      js = table_spreadsheet_chartwrapper.table.append_data(data_spreadsheet)
      expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
    end
    it "should return option dataTable otherwise" do
      js = table_chartwrapper.table.append_data(data)
      expect(js).to match(/dataTable: data_table/)
    end
  end

  describe "#extract_option_view" do
    it "should return value of view option if view option is provided" do
      js = table_spreadsheet_chartwrapper.table.extract_option_view
      expect(js).to eq('{columns: [0,1]}')
    end
    it "should return '' if view option is not provided" do
      js = table_chartwrapper.table.extract_option_view
      expect(js).to eq('\'\'')
    end
  end

  describe "#draw_wrapper" do
    it "should draw the chartwrapper only when class_chart is"\
       " set to Chartwrapper" do
      js = table_chartwrapper.table.draw_wrapper
      expect(js).to match(/wrapper.draw\(\);/)
    end
    it "should draw the chartwrapper only when class_chart is"\
       " set to Chartwrapper" do
      js = table_spreadsheet.table.draw_wrapper
      expect(js).to eql("")
    end
  end

  describe "#load_js" do
  	it "loads valid packages" do
    js = data_table.table.load_js('id')
  	expect(js).to match(/google.load\('visualization', 1.0,/i)
  	expect(js).to match(/\{packages: \['table'\], callback:/i)
    expect(js).to match(/draw_id\}\)/i)
  	end
  end

  describe "#load_js_chart_wrapper" do
    it "load valid JS of the ChartWrapper" do
      js = table_chartwrapper.table.load_js_chart_wrapper('id')
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback:\n draw_id/)
    end
  end

  describe "#draw_js" do
  	it "draws valid JS of the table" do
  	  js = data_table.table.draw_js('id')
  	  expect(js).to match(/google.visualization.DataTable\(\)/i)
  	  expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.Table/i)
      expect(js).to match(/table.draw\(data_table, \{\}/i)
  	end
  end

  describe "#draw_js_chart_wrapper" do
    it "draws valid JS of the ChartWrapper" do
      js = table_chartwrapper.table.draw_js_chart_wrapper(data, 'id')
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: \{\}/)
      expect(js).to match(/containerId: 'id'/)
    end
  end
end
