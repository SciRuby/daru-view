require 'securerandom'
require 'erb'
require_relative 'data_table_iruby'
require_relative 'base_chart'
require 'daru/view/constants'

module GoogleVisualr
  def self.init_script(
    dependent_js=GOOGLECHARTS_DEPENDENCIES
  )
    js =  ''
    js << "\n<script type='text/javascript'>"
    js << GoogleVisualr.generate_init_code(dependent_js)
    js << "\n</script>"
    js
  end

  module Display
    # Holds a value only when to_html method is invoked
    # @return [String] The ID of the DIV element that the Google Chart or
    #   Google DataTable should be rendered in
    attr_accessor :html_id

    def show_script(dom=SecureRandom.uuid, options={})
      script_tag = options.fetch(:script_tag) { true }
      if script_tag
        show_script_with_script_tag(dom)
      # Without checking for user_options, data as hash was not working!
      elsif user_options && user_options[:chart_class]
        case user_options[:chart_class].to_s.capitalize
        when 'Chartwrapper'
          get_html_chart_wrapper(data, dom)
        when 'Charteditor'
          get_html_chart_editor(data, dom)
        end
      elsif data.is_a?(String)
        get_html_spreadsheet(data, dom)
      else
        get_html(dom)
      end
    end

    # @param dom [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] js code to render the chart with script tag
    def show_script_with_script_tag(dom=SecureRandom.uuid)
      # if it is data table
      if user_options &&
         user_options[:chart_class].to_s.capitalize == 'Chartwrapper'
        to_js_chart_wrapper(data, dom)
      elsif data.is_a?(String)
        to_js_spreadsheet(data, dom)
      elsif is_a?(GoogleVisualr::DataTable)
        to_js_full_script(dom)
      else
        to_js(dom)
      end
    end

    # @param dom [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] js code to render the chart
    def get_html(dom)
      html = ''
      html << load_js(dom)
      html << draw_js(dom)
      html
    end

    # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
    #   Data of GoogleVisualr Chart or GoogleVisualr DataTable
    # @param dom [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] js code to render the chart
    def get_html_chart_wrapper(data, dom)
      html = ''
      html << load_js(dom)
      html << draw_js_chart_wrapper(data, dom)
      html
    end

    # @param data [Array, Daru::DataFrame, Daru::Vector, Daru::View::Table, String]
    #   Data of GoogleVisualr Chart or GoogleVisualr DataTable
    # @param dom [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] js code to render the charteditor
    def get_html_chart_editor(data, dom)
      html = ''
      html << if is_a?(GoogleVisualr::DataTable)
                load_js(dom)
              else
                load_js_chart_editor(dom)
              end
      html << draw_js_chart_editor(data, dom)
      html
    end

    # @param data [String] URL of the google spreadsheet in the specified
    #   format: https://developers.google.com/chart/interactive/docs
    #   /spreadsheets
    #   Query string can be appended to retrieve the data accordingly
    # @param dom [String] The ID of the DIV element that the Google
    #   Chart should be rendered in when data is the the URL of the google
    #   spreadsheet
    # @return [String] js code to render the chart when data is the URL of
    #   the google spreadsheet
    def get_html_spreadsheet(data, dom)
      html = ''
      html << load_js(dom)
      html << draw_js_spreadsheet(data, dom)
      html
    end

    def to_html(id=nil, options={})
      path = File.expand_path(
        '../../templates/googlecharts/chart_div.erb', __dir__
      )
      template = File.read(path)
      id ||= SecureRandom.uuid
      @html_id = id
      chart_script = show_script(id, script_tag: false)
      ERB.new(template).result(binding)
    end

    def show_in_iruby(dom=SecureRandom.uuid)
      IRuby.html to_html(dom)
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
      js = ''
      js << "\n  var wrapper_#{element_id.tr('-', '_')} = null;"
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

  class DataTable
    include Display
  end

  class BaseChart
    include Display
  end
end
