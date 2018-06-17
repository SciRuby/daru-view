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
      elsif class_chart == 'Chartwrapper'
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
      if class_chart == 'Chartwrapper'
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
  end

  class DataTable
    include Display
  end

  class BaseChart
    include Display
  end
end
