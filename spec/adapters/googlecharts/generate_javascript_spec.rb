require 'spec_helper.rb'

describe GenerateJavascript do
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
  let (:table_spreadsheet) {
    Daru::View::Table.new(
      data_spreadsheet, {width: 800}
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
  let(:user_options_listener) {{
    listeners: {
      select: "alert('A table row was selected');"
    }
  }}
  let(:data_table) {Daru::View::Table.new(data, {}, user_options_listener)}
  let(:area_chart_chart) { Daru::View::Plot.
    new(data_table.table, area_chart_options)}
  let(:column_chart_chart) { Daru::View::Plot.new(
    data_table.table,
    column_chart_options,
    user_options_listener)
  }
  let(:area_chart_wrapper) {Daru::View::Plot.new(
    data_table.table,
    area_chart_options,
    {chart_class: 'Chartwrapper'})
  }
  let(:table_chart_wrapper) {Daru::View::Table.new(
    data, {}, user_options)
  }
  let(:plot_charteditor) {Daru::View::Plot.new(
    data, {}, chart_class: 'Charteditor')
  }
  let (:plot_spreadsheet_charteditor) {
    Daru::View::Plot.new(
      data_spreadsheet,
      {width: 800}, chart_class: 'Charteditor'
    )
  }
  let (:table_spreadsheet_charteditor) {
    Daru::View::Table.new(
      data_spreadsheet,
      {width: 800}, chart_class: 'Charteditor'
    )
  }
  let(:table_charteditor) {Daru::View::Table.new(
    data, {}, chart_class: 'Charteditor')
  }
  let(:area_wrapper_spreadsheet) {
    Daru::View::Plot.new(
      data_spreadsheet,
      {type: :area},
      user_options
    )
  }
  let (:table_spreadsheet_chartwrapper) {
    Daru::View::Table.new(
      data_spreadsheet,
      {width: 800, view: {columns: [0, 1]}},
      chart_class: 'ChartWrapper'
    )
  }

  describe "#add_listeners_js" do
    it "appends the js to add the listener in google charts" do
      plot_spreadsheet.chart.add_listener('select', "alert('A table row was selected');")
      js = plot_spreadsheet.chart.add_listeners_js('chart')
      expect(js).to match(/google.visualization.events.addListener\(/)
      expect(js).to match(/chart, 'select', function \(e\) {/)
      expect(js).to match(/alert\('A table row was selected'\);/)
    end
    it "appends the js to add the listener in google datatables" do
      data_table.table.add_listener('select', "alert('A table row was selected');")
      js = data_table.table.add_listeners_js('table')
      expect(js).to match(/google.visualization.events.addListener\(/)
      expect(js).to match(/table, 'select', function \(e\) {/)
      expect(js).to match(/alert\('A table row was selected'\);/)
    end
  end

  describe "#query_response_function_name" do
    it "should generate unique function name to handle query response" do
      func = data_table.table.query_response_function_name('i-d')
      expect(func).to eq('handleQueryResponse_i_d')
    end
  end

  describe "#save_chart_function_name" do
    it "should generate unique function name to save the chart" do
      func = plot_charteditor.chart.save_chart_function_name('i-d')
      expect(func).to eq('saveChart_i_d')
    end
  end

  describe "#append_data" do
    context 'when table is drawn' do
      it "should return option dataSourceUrl if data is URL" do
        js = table_spreadsheet_chartwrapper.table.append_data(data_spreadsheet)
        expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
      end
      it "should return option dataTable otherwise" do
        js = table_chart_wrapper.table.append_data(data)
        expect(js).to match(/dataTable: data_table/)
      end
    end
    context 'when chart is drawn' do
      it "should return option dataSourceUrl if data is URL" do
        js = area_wrapper_spreadsheet.chart.append_data(data_spreadsheet)
        expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
      end
      it "should return option dataTable otherwise" do
        js = area_chart_wrapper.chart.append_data(data)
        expect(js).to match(/dataTable: data_table/)
      end
    end
  end

  describe "#extract_chart_wrapper_options" do
    context 'when chart is drawn' do
      it "should return correct options of chartwrapper" do
        js = plot_charteditor.chart.extract_chart_wrapper_options(data, 'id')
        expect(js).to match(/chartType: 'LineChart'/)
        expect(js).to match(/dataTable: data_table/)
        expect(js).to match(/options: \{\}/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/view: ''/)
      end
      it "should return correct options of chartwrapper when data is URL" do
        js = plot_spreadsheet_charteditor.chart.extract_chart_wrapper_options(
          data_spreadsheet, 'id'
        )
        expect(js).to match(/chartType: 'LineChart'/)
        expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
        expect(js).to match(/options: {width: 800/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/view: ''/)
      end
    end
    context 'when table is drawn' do
      it "should return correct options of chartwrapper" do
        js = table_charteditor.table.extract_chart_wrapper_options(data, 'id')
        expect(js).to match(/chartType: 'Table'/)
        expect(js).to match(/dataTable: data_table/)
        expect(js).to match(/options: \{\}/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/view: ''/)
      end
      it "should return correct options of chartwrapper when data is URL" do
        js = table_spreadsheet_charteditor.table.extract_chart_wrapper_options(
          data_spreadsheet, 'id'
        )
        expect(js).to match(/chartType: 'Table'/)
        expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
        expect(js).to match(/options: {width: 800/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/view: ''/)
      end
    end
  end

  describe "#draw_wrapper" do
    context 'when chart_class is ChartEditor' do
      it "creates ChartEditor object and draws the chartwrapper" do
        js = plot_charteditor.chart.draw_wrapper('id')
        expect(js).to match(/wrapper_id.draw\(\);/)
        expect(js).to match(/new google.visualization.ChartEditor()/)
        expect(js).to match(/google.visualization.events.addListener/)
        expect(js).to match(/chartEditor_id, 'ok', saveChart_id/)
      end
      it "should draw the chartwrapper only when chart_class is"\
         " set to Chartwrapper" do
        js = table_charteditor.table.draw_wrapper('id')
        expect(js).to match(/wrapper_id.draw\(\);/)
        expect(js).to match(/new google.visualization.ChartEditor()/)
        expect(js).to match(/google.visualization.events.addListener/)
        expect(js).to match(/chartEditor_id, 'ok', saveChart_id/)
      end
    end
    context 'when chart_class is Chartwrapper' do
      it "draws the chartwrapper" do
        js = area_chart_wrapper.chart.draw_wrapper('id')
        expect(js).to match(/wrapper_id.draw\(\);/)
      end
      it "draws the chartwrapper" do
        js = table_chart_wrapper.table.draw_wrapper('id')
        expect(js).to match(/wrapper_id.draw\(\);/)
      end
    end
  end

  describe "#to_js_chart_wrapper" do
    context 'when table is drawn' do
      it "draws valid JS of the ChartWrapper when data is URL of the spreadsheet" do
        js = table_spreadsheet_chartwrapper.table.to_js_chart_wrapper(
          data_spreadsheet,
          'id'
        )
        expect(js).to match(/google.load\('visualization'/)
        expect(js).to match(/callback: draw_id/)
        expect(js).to match(/new google.visualization.ChartWrapper/)
        expect(js).to match(/chartType: 'Table'/)
        expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
        expect(js).to match(/options: {width: 800/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/view: {columns: \[0,1\]}/)
      end
    end
    context 'when chart is drawn' do
      it "draws valid JS of the ChartWrapper when data is URL of the spreadsheet" do
        js = area_wrapper_spreadsheet.chart.to_js_chart_wrapper(
          data_spreadsheet,
          'id'
        )
        expect(js).to match(/google.load\('visualization'/)
        expect(js).to match(/callback: draw_id/)
        expect(js).to match(/new google.visualization.ChartWrapper/)
        expect(js).to match(/chartType: 'AreaChart'/)
        expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
        expect(js).to match(/options: {}/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/view: ''/)
      end
    end
  end

  describe "#to_js_spreadsheet" do
    context 'when table is drawn' do
      it "draws valid JS of the table when "\
         "data is imported from google spreadsheets" do
        js = table_spreadsheet.table.to_js_spreadsheet(data_spreadsheet, 'id')
        expect(js).to match(/<script type='text\/javascript'>/i)
        expect(js).to match(/google.load\(/i)
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
    context 'when chart is drawn' do
      it "generates valid JS of the chart when "\
         "data is imported from google spreadsheets" do
        js = plot_spreadsheet.chart.to_js_spreadsheet(data_spreadsheet, 'id')
        expect(js).to match(/<script type='text\/javascript'>/i)
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
    end
  end

  describe "#draw_js_chart_editor" do
    context 'when chart is drawn' do
      it "draws valid JS of the ChartEditor" do
        js = plot_charteditor.chart.draw_js_chart_editor(data, 'id')
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
        js = plot_spreadsheet_charteditor.chart.draw_js_chart_editor(data_spreadsheet, 'id')
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
    context 'when table is drawn' do
      it "draws valid JS of the ChartEditor" do
        js = table_charteditor.table.draw_js_chart_editor(data, 'id')
        expect(js).to match(/var chartEditor_id = null/)
        expect(js).to match(/new google.visualization.DataTable/)
        expect(js).to match(/new google.visualization.ChartWrapper/)
        expect(js).to match(/chartType: 'Table'/)
        expect(js).to match(/dataTable: data_table/)
        expect(js).to match(/options: {}/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/chartEditor_id.getChartWrapper\(\).draw\(/)
        expect(js).to match(/chartEditor_id.openDialog\(wrapper_id, {}\)/)
        expect(js).to match(/containerId: 'id'/)
      end
      it "draws valid JS of the ChartEditor when URL of spreadsheet is provided" do
        js = table_spreadsheet_charteditor.table.draw_js_chart_editor(data_spreadsheet, 'id')
        expect(js).to match(/var chartEditor_id = null/)
        expect(js).to match(/new google.visualization.DataTable/)
        expect(js).to match(/new google.visualization.ChartWrapper/)
        expect(js).to match(/chartType: 'Table'/)
        expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
        expect(js).to match(/options: {width: 800/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/chartEditor_id.getChartWrapper\(\).draw\(/)
        expect(js).to match(/chartEditor_id.openDialog\(wrapper_id, {}\)/)
        expect(js).to match(/containerId: 'id'/)
      end
    end
  end

  describe "#draw_js_chart_wrapper" do
    it "draws valid JS of the ChartWrapper table" do
      js = table_chart_wrapper.table.draw_js_chart_wrapper(data, 'id')
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: \{\}/)
      expect(js).to match(/containerId: 'id'/)
    end
    it "draws valid JS of the ChartWrapper" do
      js = area_chart_wrapper.chart.draw_js_chart_wrapper(data, 'id')
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'AreaChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
  end
end