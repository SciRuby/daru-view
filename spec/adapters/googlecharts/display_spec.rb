require 'spec_helper.rb'

describe Display do
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
  let(:table_charteditor) {Daru::View::Table.new(
    data, {}, chart_class: 'Charteditor')
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
    it "adds the listener to the chart from user_options" do
      js = column_chart_chart.chart.to_html("id")
      expect(js).to match(/google.visualization.events.addListener\(/)
      expect(js).to match(/chart, 'select', function \(e\) {/)
      expect(js).to match(/alert\('A table row was selected'\);/)
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
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
    it "should generate the valid JS of charteditor" do
      js = plot_charteditor.chart.to_html('id')
      expect(js).to match(/<input id="loadcharteditor_id/)
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartEditor/)
      expect(js).to match(/chartType: 'LineChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
    it "should generate the valid JS of datatable charteditor" do
      js = table_charteditor.table.to_html('id')
      expect(js).to match(/<input id="loadcharteditor_id/)
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartEditor/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end

    context 'when formatters are applied in datatables' do
      let(:data_tf) {
        [
          ['Galaxy', 'Distance', 'Brightness', 'Galaxy-Distance', 'Date'],
          ['Canis Major Dwarf', 8000, 230.3, 0, Date.parse('1920-11-16')],
          ['Sagittarius Dwarf', 24000, 4000.5, 0, Date.parse('1901-08-10')],
          ['Ursa Major II Dwarf', 30000, 1412.3, 0, Date.parse('1960-02-27')],
          ['Lg. Magellanic Cloud', 50000, 120.9, 0, Date.parse('1857-01-23')],
          ['Bootes I', 60000, 1223.1, 0, Date.parse('1947-08-15')]
        ]
      }
      let(:user_options_arrow) {{
        formatters: {
          formatter1: {
            type: 'Arrow',
            options: {
              base: 30000
            },
            columns: 1
          }
        }
      }}
      let(:user_options_bar) {{
        formatters: {
          formatter: {
            type: 'Bar',
            options: {
              base: 1000,
              width: 120
            },
            columns: 2
          }
        }
      }}
      let(:user_options_color) {{
        formatters: {
          formatter3: {
            type: 'Color',
            range: [[1000, 30000, 'red', '#000000'],
                    [40000, nil, 'green', 'pink']],
            columns: [1,2]
          }
        }
      }}
      let(:user_options_pattern) {{
        formatters: {
          formatter4: {
            type: 'Pattern',
            format_string: "{0} - {1}",
            src_cols: [0, 1],
            des_col: 3
          }
        }
      }}
      let(:user_options_number) {{
        formatters: {
          formatter5: {
            type: 'Number',
            options: {prefix: '*', negativeParens: true},
            columns: 2
          }
        }
      }}
      let(:user_options_date) {{
        formatters: {
          formatter6: {
            type: 'Date',
            options: {
              formatType: 'long'
            },
            columns: 4
          }
        }
      }}
      let(:table_arrow) {
        Daru::View::Table.new(data_tf, {allowHtml: true}, user_options_arrow)
      }
      let(:table_bar) {
        Daru::View::Table.new(data_tf, {allowHtml: true}, user_options_bar)
      }
      let(:table_date) {
        Daru::View::Table.new(data_tf, {allowHtml: true}, user_options_date)
      }
      let(:table_number) {
        Daru::View::Table.new(data_tf, {allowHtml: true}, user_options_number)
      }
      let(:table_color) {
        Daru::View::Table.new(data_tf, {allowHtml: true}, user_options_color)
      }
      let(:table_pattern) {
        Daru::View::Table.new(data_tf, {allowHtml: true}, user_options_pattern)
      }
      it "generates ArrowFormat object" do
        table_arrow.table.to_html
        expect(table_arrow.table.formatters[0]).to be_a GoogleVisualr::ArrowFormat
      end
      it "generates BarFormat object" do
        table_bar.table.to_html
        expect(table_bar.table.formatters[0]).to be_a GoogleVisualr::BarFormat
      end
      it "generates ColorFormat object" do
        table_color.table.to_html
        expect(table_color.table.formatters[0]).to be_a GoogleVisualr::ColorFormat
      end
      it "generates DateFormat object" do
        table_date.table.to_html
        expect(table_date.table.formatters[0]).to be_a GoogleVisualr::DateFormat
      end
      it "generates NumberFormat object" do
        table_number.table.to_html
        expect(
          table_number.table.formatters[0]
        ).to be_a GoogleVisualr::NumberFormat
      end
      it "generates PatternFormat object" do
        table_pattern.table.to_html
        expect(
          table_pattern.table.formatters[0]
        ).to be_a GoogleVisualr::PatternFormat
      end
      it "generates valid JS of the Arrow formatter" do
        expect(table_arrow.table.to_html).to match(
          /formatter = new google.visualization.ArrowFormat\({base: 30000}\);/
        )
        expect(table_arrow.table.to_html).to match(/formatter.format\(data_table, 1\);/)
      end
      it "generates valid JS of the Bar formatter" do
        expect(table_bar.table.to_html).to match(
          /formatter = new google.visualization.BarFormat\({base: 1000, width: 120}\)/
        )
        expect(table_bar.table.to_html).to match(/formatter.format\(data_table, 2\);/)
      end
      it "generates valid JS of the Color formatter" do
        expect(table_color.table.to_html).to match(
          /formatter = new google.visualization.ColorFormat\(\);/
        )
        expect(table_color.table.to_html).to match(
          /formatter.addRange\(1000, 30000, "red", "#000000"\);/
        )
        expect(table_color.table.to_html).to match(
          /formatter.addRange\(40000, null, "green", "pink"\);/
        )
        expect(table_color.table.to_html).to match(/formatter.format\(data_table, 1\);/)
        expect(table_color.table.to_html).to match(/formatter.format\(data_table, 2\);/)
      end
      it "generates valid JS of the Pattern formatter" do
        expect(table_pattern.table.to_html).to match(
          /formatter = new google.visualization.PatternFormat\('\{0\} - \{1\}'\);/
        )
        expect(table_pattern.table.to_html).to match(
          /formatter.format\(data_table, \[0, 1\], 3\);/
        )
      end
      it "generates valid JS of the Number formatter" do
        expect(table_number.table.to_html).to match(
          /google.visualization.NumberFormat\({prefix: "\*", negativeParens: true}\);/
        )
        expect(table_number.table.to_html).to match(/formatter.format\(data_table, 2\);/)
      end
      it "generates valid JS of the Date formatter" do
        expect(table_date.table.to_html).to match(
          /google.visualization.DateFormat\({formatType: "long"}\);/
        )
        expect(table_date.table.to_html).to match(/formatter.format\(data_table, 4\);/)
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
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartWrapper/)
      expect(js).to match(/chartType: 'Table'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
  end

  describe "#get_html_chart_editor" do
    it "should generate the valid JS of charteditor" do
      js = plot_charteditor.chart.get_html_chart_editor(data, 'id')
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartEditor/)
      expect(js).to match(/chartType: 'LineChart'/)
      expect(js).to match(/dataTable: data_table/)
      expect(js).to match(/options: {}/)
      expect(js).to match(/containerId: 'id'/)
      expect(js).to match(/view: ''/)
    end
    it "should generate the valid JS of datatable charteditor" do
      js = table_charteditor.table.get_html_chart_editor(data, 'id')
      expect(js).to match(/google.load\('visualization'/)
      expect(js).to match(/callback: draw_id/)
      expect(js).to match(/new google.visualization.ChartEditor/)
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
      expect(js).to match(/callback: draw_id/)
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

  describe "#add_listener_to_chart" do
    it "adds the listener mentioned in user_options to the chart" do
      column_chart_chart.chart.add_listener_to_chart
      expect(column_chart_chart.chart.listeners[0][:event]).to eq('select')
      expect(column_chart_chart.chart.listeners[0][:callback]).to eq(
        "alert('A table row was selected');"
      )
    end
    it "adds the listener mentioned in user_options to the datatable" do
      data_table.table.add_listener_to_chart
      expect(data_table.table.listeners[0][:event]).to eq('select')
      expect(data_table.table.listeners[0][:callback]).to eq(
        "alert('A table row was selected');"
      )
    end
  end
end
