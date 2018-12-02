require 'securerandom'
require 'erb'
require_relative 'data_table_iruby'
require_relative 'base_chart'
require_relative 'generate_javascript'
require_relative 'formatters'

module Display
  # Holds a value only when to_html method is invoked
  # @return [String] The ID of the DIV element that the Google Chart or
  #   Google DataTable should be rendered in
  attr_accessor :html_id
  attr_accessor :formatters

  def show_script(dom=SecureRandom.uuid, options={})
    script_tag = options.fetch(:script_tag) { true }
    # To understand different formatters see:
    # https://developers.google.com/chart/interactive/docs/reference#formatters
    apply_formatters if is_a?(GoogleVisualr::DataTable)
    if script_tag
      show_script_with_script_tag(dom)
    # Without checking for user_options, data as hash was not working!
    elsif user_options && user_options[:chart_class]
      extract_chart_wrapper_editor_js(dom)
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

  # ChartEditor and ChartWrapper works for both Google Charts and DataTables
  # @see dummy_rails examples for ChartEditor in shekharrajak/demo_daru-view
  #
  # @param dom [String] The ID of the DIV element that the Google
  #   Chart should be rendered in
  # @return [String] JS to draw ChartWrapper or ChartEditor
  def extract_chart_wrapper_editor_js(dom)
    case user_options[:chart_class].to_s.capitalize
    when 'Chartwrapper'
      get_html_chart_wrapper(data, dom)
    when 'Charteditor'
      get_html_chart_editor(data, dom)
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

  # @see #Daru::View::Plot.export
  def export(export_type='png', file_name='chart')
    add_listener('ready', extract_export_code(export_type, file_name))
    to_html
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
      extract_export_png_code(file_name)
    end
  end

  def to_html(id=nil, options={})
    path = File.expand_path(
      '../../templates/googlecharts/chart_div.erb', __dir__
    )
    template = File.read(path)
    id ||= SecureRandom.uuid
    @html_id = id
    add_listener_to_chart
    chart_script = show_script(id, script_tag: false)
    ERB.new(template).result(binding)
  end

  def show_in_iruby(dom=SecureRandom.uuid)
    IRuby.html to_html(dom)
  end

  # @return [void] Adds listener to the chart from the
  #   user_options[:listeners]
  def add_listener_to_chart
    return unless user_options && user_options[:listeners]

    user_options[:listeners].each do |event, callback|
      add_listener(event.to_s.downcase, callback)
    end
  end

  private

  # @return [void] applies formatters provided by the user in the
  #   third parameter
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
                 apply_date_arrow_bar_number_formatter(formatter)
               end
      @formatters << frmttr
    end
  end

  # @param formatter [Hash] formatter hash provided by the user
  # @return [GoogleVisualr::ColorFormat] adds the ColorFormat to
  #   defined columns
  # @example Color Formatter
  #   df = Daru::DataFrame.new({b: [11,12,13,14,15], a: [1,2,3,4,5],
  #     c: [11,22,33,44,55]},
  #     order: [:a, :b, :c],
  #     index: [:one, :two, :three, :four, :five])
  #
  #   user_options = {
  #     formatters: {
  #       formatter: {
  #         type: 'Color',
  #         range: [[1, 3, 'yellow', 'red'],
  #                 [20, 50, 'green', 'pink']],
  #         columns: [0,2]
  #       },
  #       formatter2: {
  #         type: 'Color',
  #         range: [[14, 15, 'blue', 'orange']],
  #         columns: 1
  #       }
  #     }
  #   }
  #
  #   # option `allowHtml: true` is necessary to make this work
  #   table = Daru::View::Table.new(df, {allowHtml: true}, user_options)
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

  # @param formatter [Hash] formatter hash provided by the user
  # @return [void] initializes default values for the color format
  def initialize_default_values(formatter)
    formatter[:range] ||= []
    formatter[:gradient_range] ||= []
    formatter[:columns] ||= 0
  end

  # @param formatter [Hash] formatter hash provided by the user
  # @return [GoogleVisualr::PatternFormat] adds the PatternFormat to
  #   destined columns
  def apply_pattern_formatter(formatter)
    formatter[:format_string] ||= ''
    formatter[:src_cols] ||= 0
    formatter[:des_col] ||= 0
    frmttr = GoogleVisualr::PatternFormat.new(formatter[:format_string].to_s)
    frmttr.src_cols = formatter[:src_cols]
    frmttr.des_col = formatter[:des_col]
    frmttr
  end

  # @param formatter [Hash] formatter hash provided by the user
  # @return [GoogleVisualr::DateFormat, GoogleVisualr::NumberFormat,
  #   GoogleVisualr::BarFormat, GoogleVisualr::ArrowFormat] adds the required
  #   format to the destined columns
  # @example
  #   df = Daru::DataFrame.new({b: [11,-12,13,14,-15], a: [-1,2,3,4,5],
  #     c: [11,22,-33,-44,55]},
  #     order: [:a, :b, :c],
  #     index: [:one, :two, :three, :four, :five])
  #
  #   user_options = {
  #     formatters: {
  #       formatter: {
  #         type: 'Number',
  #         options: {negativeParens: true},
  #         columns: [0,1,2]
  #       }
  #     }
  #   }
  #
  #   table = Daru::View::Table.new(df, {}, user_options)
  def apply_date_arrow_bar_number_formatter(formatter)
    formatter[:options] ||= {}
    formatter[:columns] ||= 0
    frmttr = GoogleVisualr.const_get(
      formatter[:type].to_s.capitalize + 'Format'
    ).new(formatter[:options])
    frmttr.columns(formatter[:columns])
    frmttr
  end
end
