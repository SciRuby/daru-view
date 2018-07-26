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
      data_spreadsheet, {width: 800}
    )
  }
  let(:data_table) {Daru::View::Table.new(data)}
  let (:table_spreadsheet_chartwrapper) {
    Daru::View::Table.new(
      data_spreadsheet,
      {width: 800, view: {columns: [0, 1]}},
      chart_class: 'ChartWrapper'
    )
  }
  let(:table_chartwrapper) {
    Daru::View::Table.new(data, {}, chart_class: 'ChartWrapper')
  }

  describe "#to_js_full_script" do
    it "generates valid JS of the table" do
      js = data_table.table.to_js_full_script('id')
      expect(js).to match(/<script type='text\/javascript'>/i)
      expect(js).to match(/google.load\(/i)
      expect(js).to match(/google.visualization.DataTable\(\)/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.Table/i)
      expect(js).to match(/table.draw\(data_table, \{\}/i)
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

  describe "#add_listener" do
    it "adds ready listener for Google datatables" do
        data_table.table.add_listener('ready', 'callback')
        expect(data_table.table.listeners[0][:event]).to eq('ready')
        expect(data_table.table.listeners[0][:callback]).to eq('callback')
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

  describe "#draw_js" do
    it "draws valid JS of the table" do
      js = data_table.table.draw_js('id')
      expect(js).to match(/google.visualization.DataTable\(\)/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.Table/i)
      expect(js).to match(/table.draw\(data_table, \{\}/i)
  	end
    it "adds correct listener" do
      data_table.table.add_listener('ready', "alert('hi');")
      js = data_table.table.draw_js('id')
      expect(js).to match(
        /google.visualization.events.addListener\(table, 'ready', function \(e\) {/
      )
      expect(js).to match(/alert\('hi'\);/)
    end
  end

  describe "#draw_js_spreadsheet" do
    it "draws valid JS of the table when "\
       "data is imported from google spreadsheets" do
      js = table_spreadsheet.table.draw_js_spreadsheet(data_spreadsheet, 'id')
      expect(js).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(js).to match(/gid=0&headers=1&tq=/i)
      expect(js).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(
        /google.visualization.Table\(document.getElementById\(\'id\'\)/
      )
      expect(js).to match(/table.draw\(data_table, \{width: 800\}/i)
    end
  end
end
