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
  let(:area_chart_chart) {Daru::View::Plot.
    new(data_table.table, area_chart_options)}
  let(:column_chart_chart) {Daru::View::Plot.
  new(data_table.table, column_chart_options)}
  let(:area_chart_wrapper) {Daru::View::Plot.new(
    data_table.table,
    area_chart_options,
    user_options)
  }
  let(:area_wrapper_spreadsheet) {
    Daru::View::Plot.new(
      data_spreadsheet,
      {type: :area},
      chart_class: 'ChartWrapper'
    )
  }
  let (:table_spreadsheet_chartwrapper) {
    Daru::View::Table.new(
      data_spreadsheet,
      {width: 800, view: {columns: [0, 1]}},
      chart_class: 'ChartWrapper'
    )
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

    context 'when formatters are applied in datatables' do
      let(:data_tf) {
        [
          ['Galaxy', 'Distance', 'Brightness', 'Galaxy-Distance', 'Date of discovery'],
          ['Canis Major Dwarf', 8000, 230.3, 0, Date.parse('1920-11-16')],
          ['Sagittarius Dwarf', 24000, 4000.5, 0, Date.parse('1901-08-10')],
          ['Ursa Major II Dwarf', 30000, 1412.3, 0, Date.parse('1960-02-27')],
          ['Lg. Magellanic Cloud', 50000, 120.9, 0, Date.parse('1857-01-23')],
          ['Bootes I', 60000, 1223.1, 0, Date.parse('1947-08-15')]
        ]
      }
      let(:user_options_ftr) {{
        formatters: {
          formatter1: {
            type: 'Arrow',
            options: {
              base: 30000
            },
            columns: 1
          },
          formatter2: {
            type: 'Bar',
            options: {
              base: 1000,
              width: 120
            },
            columns: 2
          },
          formatter3: {
            type: 'Color',
            range: [[1000, 30000, 'red', '#000000'],
                    [40000, nil, 'green', 'pink']],
            columns: [1,2]
          },
          formatter4: {
            type: 'Pattern',
            format_string: "{0} - {1}",
            src_cols: [0, 1],
            des_col: 3
          },
          formatter5: {
            type: 'Number',
            options: {prefix: '*', negativeParens: true},
            columns: 2
          },
          formatter6: {
            type: 'Date',
            options: {
              formatType: 'long'
            },
            columns: 4
          }
        }
      }}
      let(:tf) {
        Daru::View::Table.new(data_tf, {allowHtml: true}, user_options_ftr)
      }
      it "generates valid JS of the Arrow formatter" do
        expect(tf.table.to_html).to match(
          /formatter = new google.visualization.ArrowFormat\({base: 30000}\);/
        )
        expect(tf.table.to_html).to match(/formatter.format\(data_table, 1\);/)
      end
      it "generates valid JS of the Bar formatter" do
        expect(tf.table.to_html).to match(
          /formatter = new google.visualization.BarFormat\({base: 1000, width: 120}\)/
        )
        expect(tf.table.to_html).to match(/formatter.format\(data_table, 2\);/)
      end
      it "generates valid JS of the Color formatter" do
        expect(tf.table.to_html).to match(
          /formatter = new google.visualization.ColorFormat\(\);/
        )
        expect(tf.table.to_html).to match(
          /formatter.addRange\(1000, 30000, "red", "#000000"\);/
        )
        expect(tf.table.to_html).to match(
          /formatter.addRange\(40000, null, "green", "pink"\);/
        )
        expect(tf.table.to_html).to match(/formatter.format\(data_table, 1\);/)
        expect(tf.table.to_html).to match(/formatter.format\(data_table, 2\);/)
      end
      it "generates valid JS of the Pattern formatter" do
        expect(tf.table.to_html).to match(
          /formatter = new google.visualization.PatternFormat\('\{0\} - \{1\}'\);/
        )
        expect(tf.table.to_html).to match(
          /formatter.format\(data_table, \[0, 1\], 3\);/
        )
      end
      it "generates valid JS of the Number formatter" do
        expect(tf.table.to_html).to match(
          /google.visualization.NumberFormat\({prefix: "\*", negativeParens: true}\);/
        )
        expect(tf.table.to_html).to match(/formatter.format\(data_table, 2\);/)
      end
      it "generates valid JS of the Date formatter" do
        expect(tf.table.to_html).to match(
          /google.visualization.DateFormat\({formatType: "long"}\);/
        )
        expect(tf.table.to_html).to match(/formatter.format\(data_table, 4\);/)
      end
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

  describe "#query_response_function_name" do
    it "should generate unique function name to handle query response" do
      func = data_table.table.query_response_function_name('i-d')
      expect(func).to eq('handleQueryResponse_i_d')
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

  describe "#draw_wrapper" do
    context 'when table is drawn' do
      it "should draw the chartwrapper only if chart_class is"\
         " set to Chartwrapper" do
        js = table_chart_wrapper.table.draw_wrapper
        expect(js).to match(/wrapper.draw\(\);/)
      end
    end
    context 'when chart is drawn' do
      it "should draw the chartwrapper only if chart_class is"\
         " set to Chartwrapper" do
        js = area_chart_wrapper.chart.draw_wrapper
        expect(js).to match(/wrapper.draw\(\);/)
      end
    end
    it "should draw the chartwrapper only if chart_class is"\
       " set to Chartwrapper" do
      js = plot_spreadsheet.chart.draw_wrapper
      expect(js).to eql("")
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
        expect(js).to match(/callback:\n draw_id/)
        expect(js).to match(/new google.visualization.ChartWrapper/)
        expect(js).to match(/chartType: 'Table'/)
        expect(js).to match(/dataSourceUrl: 'https:\/\/docs.google/)
        expect(js).to match(/options: {width: 800/)
        expect(js).to match(/containerId: 'id'/)
        expect(js).to match(/view: {columns: \[0,1\]}/)
      end
    end
    context 'when chart is drawn' do
      it "generates valid JS of the table when "\
         "data is imported from google spreadsheets" do
        js = table_spreadsheet_chartwrapper.table.to_js_spreadsheet(
          data_spreadsheet, 'id'
        )
        expect(js).to match(/<script type='text\/javascript'>/i)
        expect(js).to match(/google.load\(/i)
        expect(js).to match(/https:\/\/docs.google.com\/spreadsheets/i)
        expect(js).to match(/gid=0&headers=1&tq=/i)
        expect(js).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
        expect(js).to match(/var data_table = response.getDataTable/i)
        expect(js).to match(
          /google.visualization.Table\(document.getElementById\(\'id\'\)/
        )
        expect(js).to match(/table.draw\(data_table, \{width: 800/i)
      end
    end
  end

  describe "#to_js_spreadsheet" do
    context 'when table is drawn' do
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
end
