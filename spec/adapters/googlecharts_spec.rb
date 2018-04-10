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
    # TODO: all other kinds of charts
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
    it "Raise error when data objects are none of the above" do
      expect{Daru::View::Table.new("daru")}.to raise_error(ArgumentError) 
    end
  end

  describe "#generate_body" do
    it "generates valid JS of the Area Chart" do
      js = area_chart_chart.adapter.generate_body(area_chart_chart.chart)
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
      js = column_chart_chart.adapter.generate_body(column_chart_chart.chart)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.ColumnChart/i)
      expect(js).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid JS of the google data_table" do
      js = data_table.adapter.generate_body(data_table.table)
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
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
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
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
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
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
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
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
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
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
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
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
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(content).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
    end
  end
end
