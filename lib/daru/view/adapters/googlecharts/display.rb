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
      elsif class_chart == 'Chartwrapper'
        get_html_chart_wrapper(data, dom)
      elsif class_chart == 'Charteditor'
        get_html_chart_editor(data, dom)
      else
        html = ''
        html << load_js(dom)
        html << draw_js(dom)
        html
      end
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

    # @param dom [String] The ID of the DIV element that the Google
    #   Chart should be rendered in
    # @return [String] js code to render the chart with script tag
    def show_script_with_script_tag(dom=SecureRandom.uuid)
      # if it is data table
      if is_a?(GoogleVisualr::DataTable) && class_chart == 'Chartwrapper'
        to_js_full_script_chart_wrapper(data, dom)
      elsif is_a?(GoogleVisualr::DataTable)
        to_js_full_script(dom)
      elsif class_chart == 'Chartwrapper'
        to_js_chart_wrapper(data, dom)
      else
        to_js(dom)
      end
    end

    def to_html(id=nil, options={})
      path =
        if class_chart == 'Charteditor'
          File.expand_path(
            '../../templates/googlecharts/chart_editor_div.erb', __dir__
          )
        else
          File.expand_path('../../templates/googlecharts/chart_div.erb', __dir__)
        end
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
