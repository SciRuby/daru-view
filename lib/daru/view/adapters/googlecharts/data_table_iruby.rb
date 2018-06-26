require 'securerandom'
require 'google_visualr'

module GoogleVisualr
  class DataTable
    # Holds a value only when generate_body or show_in_iruby method
    #   is invoked in googlecharts.rb
    # @return [Array, Daru::DataFrame, Daru::Vector, String] Data of
    #   GoogleVisualr DataTable
    attr_accessor :data
    # options will enable us to give some styling for table.
    # E.g. pagination, row numbers, etc
    attr_accessor :options, :listeners
    # included to use `js_parameters` method
    include GoogleVisualr::ParamHelpers

    # overiding the current initialze method (of the google_visualr).
    # This might be not a good idea. But right now I need these lines in it :
    # ` unless options[:cols].nil?` , `unless options[:rows].nil?` and
    # `@options = options`
    # Few lines is changed, to fix rubocop error.
    def initialize(options={})
      @cols = []
      @rows = []
      @listeners = []
      @options = options
      return if options.empty?

      new_columns(options[:cols]) unless options[:cols].nil?

      return if options[:rows].nil?
      rows = options[:rows]
      rows.each do |row|
        add_row(row[:c])
      end
    end

    # Adds a listener to the array of listeners
    #
    # @param event [String] name of the event tha will be fired
    # @param callback [String] callback function name for the event
    # @return [Array] array of listeners
    def add_listener(event, callback)
      @listeners << {event: event.to_s, callback: callback}
    end

    # Generates JavaScript and renders the Google Chart DataTable in the
    #   final HTML output
    #
    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart DataTable should be rendered in
    # @return [String] Javascript code to render the Google Chart DataTable
    def to_js_full_script(element_id=SecureRandom.uuid)
      js =  ''
      js << '\n<script type=\'text/javascript\'>'
      js << load_js(element_id)
      js << draw_js(element_id)
      js << '\n</script>'
      js
    end

    # Generates JavaScript and renders the Google Chart DataTable in the
    #   final HTML output when data is URL of the google spreadsheet
    #
    # @param data [String] URL of the google spreadsheet in the specified
    #   format: https://developers.google.com/chart/interactive/docs
    #   /spreadsheets
    #   Query string can be appended to retrieve the data accordingly
    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart DataTable should be rendered in
    # @return [String] Javascript code to render the Google Chart DataTable
    #   when data is given as the URL of the google spreadsheet
    def to_js_full_script_spreadsheet(data, element_id=SecureRandom.uuid)
      js =  ''
      js << '\n<script type=\'text/javascript\'>'
      js << load_js(element_id)
      js << draw_js_spreadsheet(data, element_id)
      js << '\n</script>'
      js
    end

    def chart_function_name(element_id)
      "draw_#{element_id.tr('-', '_')}"
    end

    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart DataTable should be rendered in
    # @return [String] unique function name to handle query response
    def query_response_function_name(element_id)
      "handleQueryResponse_#{element_id.tr('-', '_')}"
    end

    def google_table_version
      '1.0'.freeze
    end

    def package_name
      'table'
    end

    # @return [String] js function to add the listener to the chart
    def add_listeners_js
      js = ''
      @listeners.each do |listener|
        js << "\n    google.visualization.events.addListener("
        js << "table, '#{listener[:event]}', function (e) {"
        js << "\n      #{listener[:callback]}"
        js << "\n    });"
      end
      js
    end

    # Generates JavaScript for loading the appropriate Google Visualization
    #   package, with callback to render chart.
    #
    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart DataTable should be rendered in
    # @return [String] JS to load to appropriate Google Visualization package
    def load_js(element_id)
      js = ''
      js << "\n  google.load('visualization', #{google_table_version}, "
      js << "\n {packages: ['#{package_name}'], callback:"
      js << "\n #{chart_function_name(element_id)}});"
      js
    end

    # Generates JavaScript function for rendering the google chart table.
    #
    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart DataTable should be rendered in
    # @return [String] JS function to render the google chart table
    def draw_js(element_id)
      js = ''
      js << "\n  function #{chart_function_name(element_id)}() {"
      js << "\n    #{to_js}"
      js << "\n    var table = new google.visualization.Table("
      js << "\n    document.getElementById('#{element_id}'));"
      js << add_listeners_js
      js << "\n    table.draw(data_table, #{js_parameters(@options)}); "
      js << "\n  };"
      js
    end

    # Generates JavaScript function for rendering the google chart table when
    #   data is URL of the google spreadsheet
    #
    # @param (see #to_js_full_script_spreadsheet)
    # @return [String] JS function to render the google chart table when data
    #   is URL of the google spreadsheet
    def draw_js_spreadsheet(data, element_id)
      js = ''
      js << "\n function #{chart_function_name(element_id)}() {"
      js << "\n 	var query = new google.visualization.Query('#{data}');"
      js << "\n 	query.send(#{query_response_function_name(element_id)});"
      js << "\n }"
      js << "\n function #{query_response_function_name(element_id)}(response) {"
      js << "\n 	var data_table = response.getDataTable();"
      js << "\n 	var table = new google.visualization.Table"\
            "(document.getElementById('#{element_id}'));"
      js << "\n 	table.draw(data_table, #{js_parameters(@options)});"
      js << "\n };"
      js
    end
  end
end
