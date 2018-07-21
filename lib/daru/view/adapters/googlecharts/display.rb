require 'securerandom'
require 'erb'
require_relative 'data_table_iruby'
require_relative 'base_chart'
require 'daru/view/constants'
require_relative 'formatters'

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
      # To understand different formatters see:
      # https://developers.google.com/chart/interactive/docs/reference#formatters
      apply_formatters if is_a?(GoogleVisualr::DataTable)
      if script_tag
        show_script_with_script_tag(dom)
      # Without checking for user_options, data as hash was not working!
      elsif user_options &&
            user_options[:chart_class].to_s.capitalize == 'Chartwrapper'
        get_html_chart_wrapper(data, dom)
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

    def get_html_chart_wrapper(data, dom)
      html = ''
      html << load_js(dom)
      html << draw_js_chart_wrapper(data, dom)
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

    # So that it can be used in ChartEditor also
    #
    # @return [String] Returns string to draw the Chartwrapper and '' otherwise
    def draw_wrapper
      return "\n  \twrapper.draw();" if
      user_options[:chart_class].to_s.capitalize == 'Chartwrapper'
      ''
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

    private

    def apply_formatters
      return unless user_options && user_options[:formatters]
      @formatters = []
      user_options[:formatters].each_value do |formatter|
        frmttr = case formatter[:type].to_s.capitalize
                 when 'Color'
                   apply_color_formatter(formatter)
                 when 'Pattern'
                   apply_pattern_formatter(formatter)
                 else
                   apply_remaining_formatter(formatter)
                 end
        @formatters << frmttr
      end
    end

    def apply_color_formatter(formatter)
      initialize_default_values(formatter)
      frmttr = GoogleVisualr::ColorFormat.new
      formatter[:range].each do |range|
        # add_range parameters: (from, to, color, bgcolor)
        frmttr.add_range(range[0], range[1], range[2], range[3])
      end
      formatter[:gradient_range].each do |gr|
        # add_range parameters: (from, to, color, fromBgColor, toBgColor)
        frmttr.add_gradient_range(gr[0], gr[1], gr[2], gr[3], gr[4])
      end
      frmttr.columns(formatter[:columns])
      frmttr
    end

    def initialize_default_values(formatter)
      formatter[:range] ||= []
      formatter[:gradient_range] ||= []
      formatter[:columns] ||= 0
    end

    def apply_pattern_formatter(formatter)
      formatter[:format_string] ||= ''
      formatter[:src_cols] ||= 0
      formatter[:des_col] ||= 0
      frmttr = GoogleVisualr::PatternFormat.new(formatter[:format_string].to_s)
      frmttr.src_cols = formatter[:src_cols]
      frmttr.des_col = formatter[:des_col]
      frmttr
    end

    def apply_remaining_formatter(formatter)
      formatter[:options] ||= {}
      formatter[:columns] ||= 0
      frmttr = GoogleVisualr.const_get(
        formatter[:type].to_s.capitalize + 'Format'
      ).new(formatter[:options])
      frmttr.columns(formatter[:columns])
      frmttr
    end
  end

  class DataTable
    include Display
  end

  class BaseChart
    include Display
  end
end
