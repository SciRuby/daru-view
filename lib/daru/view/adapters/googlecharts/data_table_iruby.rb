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
    # @return [Hash] Various options created to facilitate more features.
    #   These will be provided by the user
    attr_accessor :user_options

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

    def chart_function_name(element_id)
      "draw_#{element_id.tr('-', '_')}"
    end

    def google_table_version
      '1.0'.freeze
    end

    def package_name
      return 'table' unless
      user_options && user_options[:chart_class].to_s.capitalize == 'Charteditor'

      'charteditor'
    end

    # @return [String] Returns value of the view option provided by the user
    #   and '' otherwise
    def extract_option_view
      return js_parameters(@options.delete(:view)) unless @options[:view].nil?

      '\'\''
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
      js << " {packages: ['#{package_name}'], callback:"
      js << " #{chart_function_name(element_id)}});"
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
      js << "document.getElementById('#{element_id}'));"
      js << add_listeners_js('table')
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
      js << "\n   var query = new google.visualization.Query('#{data}');"
      js << "\n   query.send(#{query_response_function_name(element_id)});"
      js << "\n }"
      js << "\n function #{query_response_function_name(element_id)}(response) {"
      js << "\n   var data_table = response.getDataTable();"
      js << "\n   var table = new google.visualization.Table"\
            "(document.getElementById('#{element_id}'));"
      js << add_listeners_js('table')
      js << "\n 	table.draw(data_table, #{js_parameters(@options)});"
      js << "\n };"
      js
    end
  end
end
