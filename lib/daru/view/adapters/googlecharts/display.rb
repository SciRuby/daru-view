require 'securerandom'
require 'erb'
require_relative 'data_table_iruby'

module GoogleVisualr
  def self.init_script(
    dependent_js=['google_visualr.js', 'loader.js']
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

    # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
    def show_script(dom=SecureRandom.uuid, options={})
      script_tag = options.fetch(:script_tag) { true }
      if script_tag
        # if it is data table and importing data from spreadsheet
        if is_a?(GoogleVisualr::DataTable) && data.is_a?(String)
          to_js_full_script_spreadsheet(data, dom)
        elsif is_a?(GoogleVisualr::DataTable)
          to_js_full_script(dom)
        # Importing data from spreadsheet
        elsif data.is_a?(String)
          to_js_spreadsheet(data, dom)
        else
          to_js(dom)
        end
      elsif data.is_a?(String)
        get_html_spreadsheet(data, dom)
      else
        get_html(dom)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity

    def get_html(dom)
      html = ''
      html << load_js(dom)
      html << draw_js(dom)
      html
    end

    def get_html_spreadsheet(data, dom)
      html = ''
      html << load_js(dom)
      html << draw_js_spreadsheet(data, dom)
      html
    end

    def to_html(id=nil, options={})
      path = File.expand_path('../../templates/googlecharts/chart_div.erb', __dir__)
      template = File.read(path)
      id ||= SecureRandom.uuid
      @html_id = id
      chart_script = show_script(id, script_tag: false)
      ERB.new(template).result(binding)
    end

    def show_in_iruby(dom=SecureRandom.uuid)
      IRuby.html(to_html(dom))
    end
  end

  class DataTable
    # Holds a value only when generate_body or show_in_iruby method
    #   is invoked in googlecharts.rb
    # Data of GoogleVisualr DataTable
    attr_accessor :data
    include Display
  end

  class BaseChart
    # Holds a value only when generate_body or show_in_iruby method
    #   is invoked in googlecharts.rb
    # Data of GoogleVisualr Chart
    attr_accessor :data
    include Display

    def query_response_function_name(element_id)
      "handleQueryResponse_#{element_id.tr('-', '_')}"
    end

    # Generates JavaScript when data is imported from spreadsheet and renders
    # the Google Chart in the final HTML output.
    #
    # Parameters:
    #  *data         [Required] The URL of the spreadsheet in a specified format.
    #                  Query string can be appended to retrieve the data
    #                  accordingly.
    #  *div_id       [Required] The ID of the DIV element that the Google Chart
    #                  DataTable should be rendered in.
    def to_js_spreadsheet(data, element_id=SecureRandom.uuid)
      js =  ''
      js << "\n<script type='text/javascript'>"
      js << load_js(element_id)
      js << draw_js_spreadsheet(data, element_id)
      js << "\n</script>"
      js
    end

    # Generates JavaScript function for rendering the chart.
    #
    # Parameters:
    #  *data         [Required] The URL of the spreadsheet in a specified format.
    #                  Query string can be appended to retrieve the data
    #                  accordingly.
    #  *div_id       [Required] The ID of the DIV element that the Google Chart
    #                  should be rendered in.
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
