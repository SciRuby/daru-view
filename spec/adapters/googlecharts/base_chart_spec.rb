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
  end

  describe "#query_response_function_name" do
    it "should generate unique function name to handle query response" do
      func = @plot_spreadsheet.chart.query_response_function_name('i-d')
      expect(func).to eq('handleQueryResponse_i_d')
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