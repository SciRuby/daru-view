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
      html << if is_a?(GoogleVisualr::DataTable)
                draw_js(dom)
              else
                draw_chart_js(dom)
              end
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
      IRuby.html(to_html(dom))
    end

    def export(export_type='png', file_name='chart')
      id = SecureRandom.uuid
      js = ''
      add_listener('ready', "exportChart_#{id.tr('-', '_')}") if
      export_type == 'png'
      js << to_html(id)
      js << extract_export_code(export_type, file_name)
      js
    end

    def export_iruby(export_type='png', file_name='chart')
      IRuby.html(export(export_type, file_name))
    end

    def extract_export_code(export_type='png', file_name='chart')
      case export_type
      when 'png'
        js = ''
        js << "\n <script>"
        js << "\n function exportChart_#{@html_id.tr('-', '_')}() {"
        js << "\n \tvar a = document.createElement('a');"
        js << "\n \ta.href = chart.getImageURI();"
        js << "\n \ta.download = '#{file_name}.png';"
        js << "\n \tdocument.body.appendChild(a);"
        js << "\n \ta.click();"
        js << "\n \tdocument.body.removeChild(a);"
        js << "\n \t}"
        js << "\n </script>"
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
