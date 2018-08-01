module GenerateJavascript
  # @return [String] js function to add the listener to the chart
  def add_listeners_js(type)
    js = ''
    @listeners.each do |listener|
      js << "\n    google.visualization.events.addListener("
      js << "#{type}, '#{listener[:event]}', function (e) {"
      js << "\n      #{listener[:callback]}"
      js << "\n    });"
    end
    js
  end

  # @param element_id [String] The ID of the DIV element that the Google
  #   Chart/DataTable should be rendered in
  # @return [String] unique function name to handle query response
  def query_response_function_name(element_id)
    "handleQueryResponse_#{element_id.tr('-', '_')}"
  end

  # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
  #   Data of GoogleVisualr DataTable/Chart
  # @return [String] Data option (dataSourceUrl or dataTable) required to
  #   draw the Chartwrapper based upon the data provided.
  def append_data(data)
    return "\n  \t\tdataSourceUrl: '#{data}'," if data.is_a? String
    "\n  \t\tdataTable: data_table,"
  end

  # @param element_id [String] The ID of the DIV element that the Google
  #   Chart should be rendered in
  # @return [String] unique function name to save the chart
  def save_chart_function_name(element_id)
    "saveChart_#{element_id.tr('-', '_')}"
  end

  # @param (see #draw_js_chart_editor)
  # @return [String] options of the ChartWrapper
  def extract_chart_wrapper_options(data, element_id)
    js = ''
    js << if is_a?(GoogleVisualr::DataTable)
            "\n  \t\tchartType: 'Table',"
          else
            "\n  \t\tchartType: '#{chart_name}',"
          end
    js << append_data(data)
    js << "\n  \t\toptions: #{js_parameters(@options)},"
    js << "\n  \t\tcontainerId: '#{element_id}',"
    js << "\n  \t\tview: #{extract_option_view}"
    js
  end

  # So that it can be used in ChartEditor also
  #
  # @return [String] Returns string to draw the Chartwrapper and '' otherwise
  def draw_wrapper(element_id)
    js = ''
    js << "\n  \twrapper_#{element_id.tr('-', '_')}.draw();"
    unless user_options[:chart_class].to_s.capitalize == 'Chartwrapper'
      js << "\n  \tchartEditor_#{element_id.tr('-', '_')} = "\
            'new google.visualization.ChartEditor();'
      js << "\n  \tgoogle.visualization.events.addListener("\
            "chartEditor_#{element_id.tr('-', '_')},"\
            " 'ok', #{save_chart_function_name(element_id)});"
    end
    js
  end

  # Generates JavaScript and renders the Google Chartwrapper in the
  #   final HTML output.
  #
  # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
  #   Data of GoogleVisualr Chart/DataTable
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

  # Generates JavaScript when data is imported from spreadsheet and renders
  #   the Google Chart/Table in the final HTML output when data is URL of the
  #   google spreadsheet
  #
  # @param data [String] URL of the google spreadsheet in the specified
  #   format: https://developers.google.com/chart/interactive/docs
  #   /spreadsheets
  #   Query string can be appended to retrieve the data accordingly
  # @param element_id [String] The ID of the DIV element that the Google
  #   Chart/Table should be rendered in
  # @return [String] Javascript code to render the Google Chart/Table when
  #   data is given as the URL of the google spreadsheet
  def to_js_spreadsheet(data, element_id=SecureRandom.uuid)
    js =  ''
    js << "\n<script type='text/javascript'>"
    js << load_js(element_id)
    js << draw_js_spreadsheet(data, element_id)
    js << "\n</script>"
    js
  end

  # Generates JavaScript function for rendering the chartwrapper
  #
  # @param (see #to_js_chart_wrapper)
  # @return [String] JS function to render the chartwrapper
  def draw_js_chart_wrapper(data, element_id)
    js = "\n  var wrapper_#{element_id.tr('-', '_')} = null;"
    js << "\n  function #{chart_function_name(element_id)}() {"
    js << if is_a?(GoogleVisualr::DataTable)
            "\n  \t#{to_js}"
          else
            "\n  \t#{@data_table.to_js}"
          end
    js << "\n  \twrapper_#{element_id.tr('-', '_')} = "\
          'new google.visualization.ChartWrapper({'
    js << extract_chart_wrapper_options(data, element_id)
    js << "\n  \t});"
    js << draw_wrapper(element_id)
    js << add_listeners_js("wrapper_#{element_id.tr('-', '_')}")
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
    js << "\n  \tchartEditor_#{element_id.tr('-', '_')}.getChartWrapper()."\
          "draw(document.getElementById('#{element_id}'));"
    js << "\n  }"
    js << "\n  function loadEditor_#{element_id.tr('-', '_')}(){"
    js << "\n  \tchartEditor_#{element_id.tr('-', '_')}.openDialog("\
          "wrapper_#{element_id.tr('-', '_')}, {});"
    js << "\n  }"
    js
  end
end
