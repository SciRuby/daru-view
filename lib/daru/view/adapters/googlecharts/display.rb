require 'securerandom'
require 'erb'
require_relative 'data_table_iruby'
require_relative 'base_chart'

module GoogleVisualr
  def self.init_script(
    dependent_js=['google_visualr.js', 'loader.js', 'jspdf.min.js',
                  'jquery.min.js', 'xepOnline.jqPlugin.js']
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
      add_listener('ready', add_namespace(id)) unless
      defined?(IRuby)
      chart_script = show_script(id, script_tag: false)
      ERB.new(template).result(binding)
    end

    def show_in_iruby(dom=SecureRandom.uuid)
      IRuby.html(to_html(dom))
    end

    # @param element_id [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] js function to add namespace on the generated svg
    def add_namespace(id=SecureRandom.uuid)
      js = ''
      js << "\n  var svg = jQuery('##{id} svg');"
      js << "\n  svg.attr('xmlns', 'http://www.w3.org/2000/svg');"
      js << "\n  svg.css('overflow','visible');"
      js
    end

    def export(export_type='png', file_name='chart')
      add_listener('ready', extract_export_code(export_type, file_name))
      js = to_html
      js
    end

    # Exports chart to different formats in IRuby notebook
    #
    # @param type [String] format to which chart has to be exported
    # @param file_name [String] The name of the file after exporting the chart
    # @return [void] loads the js code of chart along with the code to export
    #   in IRuby notebook
    def export_iruby(export_type='png', file_name='chart')
      IRuby.html(export(export_type, file_name))
    end

    # Returns the script to export the chart in different formats
    #
    # @param type [String] format to which chart has to be exported
    # @param file_name [String] The name of the file after exporting the chart
    # @return [String] the script to export the chart
    def extract_export_code(export_type='png', file_name='chart')
      case export_type
      when 'png'
        js = extract_export_png_code(file_name)
      when 'pdf'
        js = extract_export_pdf_code(file_name)
      end
      js
    end

    # @param file_name [String] The name of the file after exporting the chart
    # @return [String] the script to export the chart in png format
    def extract_export_png_code(file_name)
      js = ''
      js << "\n \tvar a = document.createElement('a');"
      js << "\n \ta.href = chart.getImageURI();"
      js << "\n \ta.download = '#{file_name}.png';"
      js << "\n \tdocument.body.appendChild(a);"
      js << "\n \ta.click();"
      js << "\n \tdocument.body.removeChild(a);"
      js
    end

    def extract_export_pdf_code(file_name)
      js = ''
      js << "\n \tvar doc = new jsPDF();"
      js << "\n \tdoc.addImage(chart.getImageURI(), 0, 0);"
      js << "\n \tdoc.save('#{file_name}.pdf');"
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
