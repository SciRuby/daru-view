require 'spec_helper.rb'

describe Daru::View::Plot, 'plotting with googlecharts' do
  before { Daru::View.plotting_library = :googlecharts }
  before(:each) do
    @data_array1 = [[1, 15], [2, 30], [4, 40]]
    @data_vec1 = Daru::Vector.new([1 ,2, 4])
    @data_vec2 = Daru::Vector.new([15 ,30, 40])
    @data_df = Daru::DataFrame.new(arr1: @data_vec1, arr2: @data_vec2)
    @options = {width: 800, height: 720}
    @plot = Daru::View::Plot.new(@data_df, @options)
    @data_hash = {
      cols: [
              {id: 'Name', label: 'Name', type: 'string'},
              {id: 'Salary', label: 'Salary', type: 'number'},
              {type: 'boolean', label: 'Full Time Employee' },
            ],
      rows: [
              {c:[{v: 'Mike'}, {v: 10000, f: '$10,000'}, {v: true}]},
              {c:[{v: 'Jim'}, {v:8000,   f: '$8,000'}, {v: false}]},
              {c:[{v: 'Alice'}, {v: 12500, f: '$12,500'}, {v: true}]},
              {c:[{v: 'Bob'}, {v: 7000,  f: '$7,000'}, {v: true}]},
            ]
    }
    @data_array2 = [
      ['Galaxy', 'Distance', 'Brightness'],
      ['Canis Major Dwarf', 8000, 230.3],
      ['Sagittarius Dwarf', 24000, 4000.5],
      ['Ursa Major II Dwarf', 30000, 1412.3],
      ['Lg. Magellanic Cloud', 50000, 120.9],
      ['Bootes I', 60000, 1223.1]
    ]
    @table_array = Daru::View::Table.new(@data_array2, @options)
    @table_dv = Daru::View::Table.new(@data_vec1, @options)
    @table_df = Daru::View::Table.new(@data_df, @options)
    @table_hash = Daru::View::Table.new(@data_hash, @options)
  end
  let(:data) do
    [
      ['Year'],
      ['2013'],
    ]
  end
  let(:user_options) {{
    listeners: {
      select: "alert('A table row was selected');"
    }
  }}
  let(:query_string) {'SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8'}
  let(:data_spreadsheet) {'https://docs.google.com/spreadsheets/d/1XWJLkAwch'\
              '5GXAt_7zOFDcg8Wm8Xv29_8PWuuW15qmAE/gviz/tq?gid=0&headers='\
              '1&tq=' << query_string}
  let (:plot_spreadsheet) {
    Daru::View::Plot.new(
      data_spreadsheet,
      {type: :column, width: 800},
      user_options
    )
  }
  let (:table_spreadsheet) {
    Daru::View::Table.new(
      data_spreadsheet, {width: 800}
    )
  }
  let(:data_table) {Daru::View::Table.new(data, {}, user_options)}
  let(:area_chart_options) {{
      type: :area
  }}
  let(:column_chart_options) {{
      type: :column
  }}
  let(:area_chart_chart) {Daru::View::Plot.
    new(data_table.table, area_chart_options)}
  let(:column_chart_chart) {Daru::View::Plot.
  new(data_table.table, column_chart_options, user_options)}
  let(:area_chart_wrapper) {Daru::View::Plot.new(
    data_table.table,
    area_chart_options,
    {chart_class: 'Chartwrapper'})
  }
  let(:table_chart_wrapper) {Daru::View::Table.new(
    data, {}, {chart_class: 'Chartwrapper'})
  }
  let(:table_wrapper_spreadsheet) {Daru::View::Table.new(
    data_spreadsheet, {}, {chart_class: 'Chartwrapper'})
  }

  describe "initialization Charts" do
    it "Default chart GoogleVisualr::Interactive::LineChart " do
      expect(Daru::View::Plot.new.chart)
      .to be_a GoogleVisualr::Interactive::LineChart
    end
    it "Bar chart GoogleVisualr::Interactive::BarChart " do
      expect(Daru::View::Plot.new(
        [],
        type: :bar).chart
      ).to be_a GoogleVisualr::Interactive::BarChart
    end
    it "Column chart GoogleVisualr::Interactive::ColumnChart " do
      expect(Daru::View::Plot.new(
        [],
        type: :column).chart
      ).to be_a GoogleVisualr::Interactive::ColumnChart
    end
    it "Import data from spreadsheet" do
      expect(plot_spreadsheet.chart)
      .to be_a GoogleVisualr::Interactive::ColumnChart
      expect(plot_spreadsheet.data).to eq data_spreadsheet
      expect(plot_spreadsheet.options).to eq 'width'=> 800
    end
    # TODO: all other kinds of charts
    it "sets correct user_options and data" do
      expect(area_chart_chart.chart.user_options).to be_empty
      expect(
        area_chart_wrapper.chart.user_options
      ).to eq :chart_class=> 'Chartwrapper'
      expect(area_chart_chart.chart.data).to eq data_table.table
    end
  end

  describe "initialization Tables" do
    it "Table class must be GoogleVisualr::DataTable " do
      expect(Daru::View::Table.new.table).to be_a GoogleVisualr::DataTable
    end
    it "Table class must be GoogleVisualr::DataTable when data objects are" \
       " of class Daru::Vector" do
      expect(@table_dv.table).to be_a GoogleVisualr::DataTable
      expect(@table_dv.options).to eq @options
      expect(@table_dv.data).to eq @data_vec1
    end
    it "Table class must be GoogleVisualr::DataTable when data objects are" \
       " of class Daru::DataFrame" do
      expect(@table_df.table).to be_a GoogleVisualr::DataTable
      expect(@table_df.options).to eq @options
      expect(@table_df.data).to eq @data_df
    end
    it "Table class must be GoogleVisualr::DataTable when data objects are" \
       " of class Array" do
      expect(@table_array.table).to be_a GoogleVisualr::DataTable
      expect(@table_array.options).to eq @options
      expect(@table_array.data).to eq @data_array2
    end
    it "Table class must be GoogleVisualr::DataTable when data objects are" \
       " of class Hash" do
      expect(@table_hash.table).to be_a GoogleVisualr::DataTable
      expect(@table_hash.options).to eq @options
      expect(@table_hash.data).to eq @data_hash
    end
    it "Table class must be GoogleVisualr::DataTable when data objects are" \
       " of class String" do
      expect(Daru::View::Table.new(data_spreadsheet).table)
      .to be_a GoogleVisualr::DataTable
    end
    it "Raise error when data objects are none of the above" do
      expect{Daru::View::Table.new(1234)}.to raise_error(ArgumentError)
    end
    it "sets correct user_options and data of the DataTable" do
      expect(data_table.table.user_options).to eq user_options
      expect(
        table_wrapper_spreadsheet.table.user_options
      ).to eq :chart_class=> 'Chartwrapper'
      expect(data_table.table.data).to eq data
      expect(table_wrapper_spreadsheet.table.data).to eq data_spreadsheet
    end
  end

  describe "#validate_url" do
    subject(:chart) { area_chart_chart.adapter }
    it "raises error for invalid URL" do
      expect{chart.validate_url('http/hi.com')}
      .to raise_error('Invalid URL')
      expect{chart.validate_url('daru')}
      .to raise_error('Invalid URL')
    end
    it "returns true for valid URL" do
      expect(chart.validate_url(data_spreadsheet))
      .to eq(true)
      expect(chart.validate_url('https://docs.google.com'))
      .to eq(true)
      expect(chart.validate_url('http://google.com'))
      .to eq(true)
    end
  end

  describe "#generate_body" do
    it "generates valid JS of the Area Chart" do
      js = area_chart_chart.adapter.generate_body(area_chart_chart.chart)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.AreaChart/i)
      expect(js).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid JS of the Column Chart" do
      js = column_chart_chart.adapter.generate_body(column_chart_chart.chart)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.events.addListener\(/)
      expect(js).to match(/chart, 'select', function \(e\) {/)
      expect(js).to match(/alert\('A table row was selected'\);/)
      expect(js).to match(/google.visualization.ColumnChart/i)
      expect(js).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid JS of the google data_table" do
      js = data_table.adapter.generate_body(data_table.table)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.events.addListener\(/)
      expect(js).to match(/table, 'select', function \(e\) {/)
      expect(js).to match(/alert\('A table row was selected'\);/)
    end
    it "generates valid JS of the DataTable when data as google spreadsheet" do
      js = table_spreadsheet.adapter.generate_body(table_spreadsheet.table)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.load\(/i)
      expect(js).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(js).to match(/gid=0&headers=1&tq=/i)
      expect(js).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(/google.visualization.Table/)
      expect(js).to match(/table.draw\(data_table, \{width: 800\}/i)
    end
    it "generates valid JS of the LineChart when data as google spreadsheet" do
      js = plot_spreadsheet.adapter.generate_body(plot_spreadsheet.chart)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.load\(/i)
      expect(js).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(js).to match(/gid=0&headers=1&tq=/i)
      expect(js).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(/google.visualization.events.addListener\(/)
      expect(js).to match(/chart, 'select', function \(e\) {/)
      expect(js).to match(/alert\('A table row was selected'\);/)
      expect(js).to match(/google.visualization.ColumnChart/)
      expect(js).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
    it "should generate valid JS of the Chartwrapper" do
      js = area_chart_wrapper.adapter.generate_body(area_chart_wrapper.chart)
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback:/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'AreaChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
    end
    it "should generate valid JS of the DataTable Chartwrapper" do
      js = table_chart_wrapper.adapter.generate_body(table_chart_wrapper.table)
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback:/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
    end
  end

  describe "#generate_html" do
    it "generates valid html of the Area Chart" do
      js = area_chart_chart.adapter.generate_html(area_chart_chart.chart)
      expect(js).to match(/html/i)
      expect(js).to match(/Chart_/i)
      expect(js).to match(/_Area/i)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.AreaChart/i)
      expect(js).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid html of the Column Chart" do
      js = column_chart_chart.adapter.generate_html(column_chart_chart.chart)
      expect(js).to match(/html/i)
      expect(js).to match(/Chart_/i)
      expect(js).to match(/_Column/i)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.ColumnChart/i)
      expect(js).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid html of the google data_table" do
      js = data_table.adapter.generate_html(data_table.table)
      expect(js).to match(/html/i)
      expect(js).to match(/Chart_/i)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
    end
  end

  describe "#init_script" do
    it "generates valid initial script" do
      js = area_chart_chart.adapter.init_script
      expect(js).to match(/<script type='text\/javascript'>/i)
      expect(js).to match(
        /var event = document.createEvent\(\"HTMLEvents\"\)/i)
      expect(js).to match(
        /event.initEvent\(\"load_google_charts\", false, false\)/i)
      expect(js).to match(/window.dispatchEvent\(event\)/i)
      expect(js).to match(
        /console.log\(\"Finish loading google charts js files\"\)/i)
    end
  end

  describe "#export_html_file" do
    it "writes valid html code of the Area Chart to the file" do
      area_chart_chart.export_html_file('./plot.html')
      path = File.expand_path('../../plot.html', __dir__)
      content = File.read(path)
      expect(content).to match(/html/i)
      expect(content).to match(/<script>/i)
      expect(content).to match(/google.visualization.DataTable\(\);/i)
      expect(content).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(content).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(content).to match(/google.visualization.AreaChart/i)
      expect(content).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "writes valid html code of the Column Chart to the file" do
      column_chart_chart.export_html_file('./plot.html')
      path = File.expand_path('../../plot.html', __dir__)
      content = File.read(path)
      expect(content).to match(/html/i)
      expect(content).to match(/<script>/i)
      expect(content).to match(/google.visualization.DataTable\(\);/i)
      expect(content).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(content).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(content).to match(/google.visualization.ColumnChart/i)
      expect(content).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "writes valid html code of the google data_table to the file" do
      data_table.export_html_file('./plot.html')
      path = File.expand_path('../../plot.html', __dir__)
      content = File.read(path)
      expect(content).to match(/html/i)
      expect(content).to match(/<script>/i)
      expect(content).to match(/google.visualization.DataTable\(\);/i)
      expect(content).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/
      )
      expect(content).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
    end
  end
end
