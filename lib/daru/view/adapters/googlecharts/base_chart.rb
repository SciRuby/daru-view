require 'securerandom'
require 'google_visualr'

module GoogleVisualr
  class BaseChart
    # Holds a value only when generate_body or show_in_iruby method
    #   is invoked in googlecharts.rb
    # @return [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
    #   Data of GoogleVisualr Chart
    attr_accessor :data

    # @see #GoogleVisualr::DataTable.query_response_function_name
    def query_response_function_name(element_id)
      "handleQueryResponse_#{element_id.tr('-', '_')}"
    end

    def add_listeners_js
      js = ''
      @listeners.each do |listener|
        js << "\n    google.visualization.events.addListener("
        js << "chart, '#{listener[:event]}', function (e) {"
        js << "\n      #{listener[:callback]}"
        js << "\n    });"
      end
      js
    end

    # Generates JavaScript when data is imported from spreadsheet and renders
    #   the Google Chart in the final HTML output when data is URL of the
    #   google spreadsheet
    #
    # @param data [String] URL of the google spreadsheet in the specified
    #   format: https://developers.google.com/chart/interactive/docs
    #   /spreadsheets
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

    # Generates JavaScript function for rendering the chart when data is URL of
    #   the google spreadsheet
    #
    # @param (see #to_js_spreadsheet)
    # @return [String] JS function to render the google chart when data is URL
    #   of the google spreadsheet
    def draw_js_spreadsheet(data, element_id=SecureRandom.uuid)
      js = ''
      js << "\n function #{chart_function_name(element_id)}() {"
      js << "\n 	var query = new google.visualization.Query('#{data}');"
      js << "\n 	query.send(#{query_response_function_name(element_id)});"
      js << "\n }"
      js << "\n function #{query_response_function_name(element_id)}(response) {"
      js << "\n 	var data_table = response.getDataTable();"
      js << "\n 	var chart = new google.#{chart_class}.#{chart_name}"\
            "(document.getElementById('#{element_id}'));"
      js << "\n 	chart.draw(data_table, #{js_parameters(@options)});"
      js << "\n };"
      js
    end

    # Taken from `draw_js` in googlevisualr. To export the chart in png format,
    #   `ready` listener should be implemented. So, `chart` variable needs to be
    #   defined global.
    #
    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] JavaScript function for rendering the chart
    def draw_chart_js(element_id)
      js = ''
      js << "\n  var chart = null;"
      js << "\n  function #{chart_function_name(element_id)}() {"
      js << "\n    #{@data_table.to_js}"
      js << "\n    chart = new google.#{chart_class}.#{chart_name}"
      js << "(document.getElementById('#{element_id}'));"
      js << add_listeners_js
      js << "\n    chart.draw(data_table, #{js_parameters(@options)});"
      js << "\n  };"
      js
    end
  end
end
