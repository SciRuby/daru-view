require 'securerandom'
require 'erb'
require_relative 'data_table_iruby'
require_relative 'base_chart'

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

    def show_script(dom=SecureRandom.uuid, options={})
      script_tag = options.fetch(:script_tag) { true }
      if script_tag
        show_script_with_script_tag(dom)
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

    def to_html(id=nil, options={})
      if data.is_a?(Array) &&
         (data[0].is_a?(Daru::View::Plot) || data[0].is_a?(Daru::View::Table))
        id, chart_script, path = extract_multiple_charts_id_script_path
      else
        id, chart_script, path = extract_chart_id_script_path(id)
      end
      template = File.read(path)
      ERB.new(template).result(binding)
    end

    def show_in_iruby(dom=SecureRandom.uuid)
      IRuby.html(to_html(dom))
    end

    # @return [Array] Array of IDs of the multiple  charts, Array of scripts
    #   of the multiple charts, path of the template used to render the
    #   multiple charts
    def extract_multiple_charts_id_script_path
      path = File.expand_path(
        '../../templates/googlecharts/multiple_charts_div.erb', __dir__
      )
      id = []
      chart_script = []
      data.each_with_index do |plot, index|
        id[index] ||= SecureRandom.uuid
        chart_script[index] = set_chart_script(plot, id[index])
      end
      [id, chart_script, path]
    end

    # @param id [String] The ID of the DIV element that the Google Chart
    #   should be rendered in
    # @return [Array] ID of the div element, script of the chart, path of
    #   the template which will be used to render the chart
    def extract_chart_id_script_path(id=nil)
      path = File.expand_path(
        '../../templates/googlecharts/chart_div.erb', __dir__
      )
      id ||= SecureRandom.uuid
      @html_id = id
      chart_script = show_script(id, script_tag: false)
      [id, chart_script, path]
    end

    # @param plot [Daru::View::Plot, Daru::View::Table] one of the plot or
    #   table objects that will be shown in a row
    # @param id [String] The ID of the DIV element that the Google Chart
    #   should be rendered in
    # @return [String] Javascript of the table or chart
    def set_chart_script(plot, id=nil)
      if plot.is_a?(Daru::View::Plot)
        plot.chart.show_script(id, script_tag: false)
      else
        plot.table.show_script(id, script_tag: false)
      end
    end
  end

  class DataTable
    include Display
  end

  class BaseChart
    include Display
  end
end
