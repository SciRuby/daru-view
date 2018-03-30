require 'spec_helper.rb'

describe GoogleVisualr::Display do
  before { Daru::View.plotting_library = :googlecharts }
  let(:data) do
    [
      ['Year'],
      ['2013'],
    ]
  end
  let(:area_chart_table) {Daru::View::Table.new(data)}
  let(:area_chart_options) {{
      type: :area
    }}
  let(:area_chart_chart) {Daru::View::Plot.
    new(area_chart_table.table, area_chart_options)}

  describe "#to_html" do
    it "generates valid JS of the google chart" do
  	  js = area_chart_chart.chart.to_html("id")
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
      expect(js).to match(/google.visualization.AreaChart/i)
      expect(js).to match(/chart.draw\(data_table, \{\}/i)
    end
    it "generates valid JS of the google data_table" do
      js = area_chart_table.table.to_html("id")
      expect(js).to match(/<script>/i)
      expect(js).to match(/google.visualization.DataTable\(\);/i)
      expect(js).to match(
        /data_table.addColumn\(\{\"type\":\"string\",\"label\":\"Year\"\}\);/i)
      expect(js).to match(
        /data_table.addRow\(\[\{v: \"2013\"\}\]\);/i)
    end
  end
end
