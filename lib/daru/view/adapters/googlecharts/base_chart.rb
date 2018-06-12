require 'securerandom'
require 'google_visualr'

module GoogleVisualr
  class BaseChart
    # Holds a value only when generate_body or show_in_iruby method
    #   is invoked in googlecharts.rb
    # @return [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
    #   Data of GoogleVisualr Chart
    attr_accessor :data
    # Provided by user and can take three values ('Chart', 'Chartwrapper'
    #   or 'Charteditor').
    # @return [String] Used to specify the class of the chart
    attr_accessor :class_chart

    # @see #GoogleVisualr::DataTable.query_response_function_name
    def query_response_function_name(element_id)
      "handleQueryResponse_#{element_id.tr('-', '_')}"
    end

    # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
    #   Data of GoogleVisualr Chart
    # @return [String] Data option (dataSourceUrl or dataTable) required to
    #   draw the Chartwrapper based upon the data provided.
    def append_data(data)
      return "\n       dataSourceUrl: '#{data}'," if data.is_a? String
      "\n       dataTable: data_table,"
    end

    # @see #GooleVisualr::DataTable.extract_option_view
    def extract_option_view
      return js_parameters(@options.delete('view')) unless @options['view'].nil?
      '\'\''
    end

    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] unique function name to save the chart
    def save_chart_function_name(element_id)
      "saveChart_#{element_id.tr('-', '_')}"
    end

    # @see #GooleVisualr::DataTable.draw_wrapper
    def draw_wrapper(element_id)
      return "\n    wrapper_#{element_id.tr('-', '_')}.draw();" if
      class_chart == 'Chartwrapper'
      js = ''
      js << "\n    wrapper_#{element_id.tr('-', '_')}.draw();"
      js << "\n    chartEditor_#{element_id.tr('-', '_')} = "\
            'new google.visualization.ChartEditor();'
      js << "\n    google.visualization.events.addListener("\
            "chartEditor_#{element_id.tr('-', '_')},"\
            " 'ok', #{save_chart_function_name(element_id)});"
      js
    end

    # @param (see #draw_js_chart_editor)
    # @return [String] options of the ChartWrapper
    def extract_chart_wrapper_options(data, element_id)
      js = ''
      js << "\n      chartType: '#{chart_name}',"
      js << append_data(data)
      js << "\n      options: #{js_parameters(@options)},"
      js << "\n      containerId: '#{element_id}',"
      js << "\n      view: #{extract_option_view}"
      js
    end

    # Generates JavaScript when data is imported from spreadsheet and renders
    #   the Google Chart in the final HTML output when data is URL of the
    #   google spreadsheet
    #
    # @param data [String] URL of the google spreadsheet in the specified
    #   format: https://developers.google.com/chart/interactive/docs/spreadsheets
    #   Query string can be appended to retrieve the data accordingly
    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] Javascript code to render the Google Chart when data is
    #   given as the URL of the google spreadsheet
    def to_js_spreadsheet(data, element_id=SecureRandom.uuid)
      js =  ''
      js << "\n<script type='text/javascript'>"
      js << load_js(element_id)
      js << draw_js_spreadsheet(data, element_id)
      js << "\n</script>"
      js
    end

    # Generates JavaScript and renders the Google Chartwrapper in the
    #   final HTML output.
    #
    # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
    #   Data of GoogleVisualr Chart
    # @param element_id [String] The ID of the DIV element that the Google
    #   Chartwrapper should be rendered in
    # @return [String] Javascript code to render the Google Chartwrapper
    def to_js_chart_wrapper(data, element_id=SecureRandom.uuid)
      js =  ''
      js << "\n<script type='text/javascript'>"
      js << load_js(element_id)
      js << draw_js_chart_wrapper(data, element_id)
      js << "\n</script>"
      js
    end

    # @param element_id [String] The ID of the DIV element that the Google
    #   ChartEditor should be rendered in
    # @return [String] Generates JavaScript for loading the charteditor package,
    #   with callback to render ChartEditor
    def load_js_chart_editor(element_id)
      js = ''
      js << "\n  google.load('visualization', '#{version}', "
      js << "\n {packages: ['charteditor'], callback:"
      js << "\n #{chart_function_name(element_id)}});"
      js
    end

    # Generates JavaScript function for rendering the chartwrapper
    #
    # @param (see #to_js_chart_wrapper)
    # @return [String] JS function to render the chartwrapper
    def draw_js_chart_wrapper(data, element_id)
      js = ''
      js << "\n  var wrapper_#{element_id.tr('-', '_')} = null;"
      js << "\n  function #{chart_function_name(element_id)}() {"
      js << "\n    #{@data_table.to_js}"
      js << "\n    wrapper_#{element_id.tr('-', '_')} = "\
            'new google.visualization.ChartWrapper({'
      js << extract_chart_wrapper_options(data, element_id)
      js << "\n    });"
      js << draw_wrapper(element_id)
      js << "\n  };"
      js
    end

    # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
    #   Data of GoogleVisualr Chart
    # @param element_id [String] The ID of the DIV element that the Google
    #   ChartEditor should be rendered in
    # @return [String] JS function to render the ChartEditor
    def draw_js_chart_editor(data, element_id)
      js = ''
      js << "\n  var chartEditor_#{element_id.tr('-', '_')} = null;"
      js << draw_js_chart_wrapper(data, element_id)
      js << "\n  function #{save_chart_function_name(element_id)}(){"
      js << "\n    chartEditor_#{element_id.tr('-', '_')}.getChartWrapper()."\
            "draw(document.getElementById('#{element_id}'));"
      js << "\n  }"
      js << "\n  function loadEditor_#{element_id.tr('-', '_')}(){"
      js << "\n    chartEditor_#{element_id.tr('-', '_')}.openDialog("\
            "wrapper_#{element_id.tr('-', '_')}, {});"
      js << "\n  }"
      js
    end

    # Generates JavaScript function for rendering the chart when data is URL of
    #   the google spreadsheet
    #
    # @param (see #to_js_spreadsheet)
    # @return [String] JS function to render the google chart when data is URL
    #   of the google spreadsheet
    def draw_js_spreadsheet(data, element_id=SecureRandom.uuid)
      js = ''
      js << "\n  function #{chart_function_name(element_id)}() {"
      js << "\n  var query = new google.visualization.Query('#{data}');"
      js << "\n  query.send(#{query_response_function_name(element_id)});"
      js << "\n  }"
      js << "\n  function #{query_response_function_name(element_id)}(response) {"
      js << "\n  var data_table = response.getDataTable();"
      js << "\n  var chart = new google.#{chart_class}.#{chart_name}"\
            "(document.getElementById('#{element_id}'));"
      js << "\n  chart.draw(data_table, #{js_parameters(@options)});"
      js << "\n  };"
      js
    end
  end
end
