require_relative 'layout_helper_iruby'
require_relative 'iruby_notebook'
require 'daru/view/constants'

module LazyHighCharts
  def self.init_script(
    dependent_js=[HIGHSTOCK, MAP, EXPORTING, HIGHCHARTS_3D, DATA]
  )
    # Highstock is based on Highcharts, meaning it has all the core
    # functionality of Highcharts, plus some additional features. So
    # highstock.js contains highcharts.js .If highstock.js is removed then
    # add highchart.js to make chart script work.
    #
    # Note: Don't reorder the dependent_js elements. It must be loaded in
    # the same sequence. Otherwise some of the JS overlap and doesn't work.
    js =  ''
    js << "\n<script type='text/javascript'>"
    js << LazyHighCharts.generate_init_code(dependent_js)
    js << "\n</script>"
    js
  end

  class HighChart
    # @example
    #
    # To display the html code of the chart, use `to_html`. To see the same
    # in IRuby notebook use `show_in_iruby`.
    # User can also use :
    # `IRuby.html chart.to_html` (or)
    # `IRuby.html chart.to_html.to_s` (or)
    # `IRuby.display chart.to_html, mime: 'text/html'`
    # to get the same chart in IRuby notebook.
    #
    def to_html(placeholder=random_canvas_id)
      chart_hash_must_be_present
      script = load_dependencies('web_frameworks')
      # Helps to denote either of the three classes.
      chart_class = extract_chart_class
      # When user wants to plot a HighMap
      if chart_class == 'Map'
        script << high_map(placeholder, self)
      # When user wants to plot a HighStock
      elsif chart_class == 'StockChart'
        script << high_stock(placeholder, self)
      # When user wants to plot a HighChart
      elsif chart_class == 'Chart'
        script << high_chart(placeholder, self)
      end
      script
    end

    def show_in_iruby(placeholder=random_canvas_id)
      # TODO : placeholder pass, in plot#div
      load_dependencies('iruby')
      IRuby.html to_html_iruby(placeholder)
    end

    # This method is not needed if `to_html` generates the same code. Here
    # `to_html` generates the code with `onload`, so there is need of
    # `high_chart_iruby` which doesn't use `onload` in chart script.
    def to_html_iruby(placeholder=random_canvas_id)
      # TODO : placeholder pass, in plot#div
      chart_hash_must_be_present
      high_chart_iruby(extract_chart_class, placeholder, self)
    end

    # Loads the dependent mapdata and dependent modules of the chart
    #
    # @param [String] to determine whether to load modules in IRuby or web
    #   frameworks
    # @return [void, String] loads the initial script of the modules for IRuby
    #   notebook and returns initial script of the modules for web frameworks
    def load_dependencies(type)
      dep_js = extract_dependencies
      if type == 'iruby'
        LazyHighCharts.init_iruby(dep_js) unless dep_js.nil?
      elsif type == 'web_frameworks'
        dep_js.nil? ? '' : LazyHighCharts.init_script(dep_js)
      end
    end

    # Extracts the required dependencies for the chart. User does not need
    #   to provide any mapdata requirement explicity in the `options`.
    #   MapData will be extracted using `options[:chart][:map]` already
    #   provided by the user. In `modules` user needs to provide the required
    #   modules (like tilemap in highcharts) in the form of Array. Once the
    #   dependency is loaded on a page, there is no need to provide it again in
    #   the `modules` option.
    #
    # @return [Array] the required dependencies (mapdata or modules)
    #   to load the chart
    # rubocop:disable Metrics/AbcSize
    def extract_dependencies
      dep_js = []
      # Mapdata dependencies
      if !options[:chart_class].nil? && options[:chart_class].capitalize == 'Map'
        dep_js.push('mapdata/' + options[:chart][:map].to_s + '.js') if
        options[:chart] && options[:chart][:map]
      end
      # Dependencies provided in modules option (of highcharts mainly
      #   like tilemap) by the user
      dep_js |= options.delete(:modules).map! { |js| "#{js}.js" } unless
      options[:modules].nil?
      dep_js
    end
    # rubocop:enable Metrics/AbcSize

    # @return [String] the class of the chart
    def extract_chart_class
      # Provided by user and can take two values ('stock' or 'map').
      chart_class = options.delete(:chart_class).to_s.capitalize unless
      options[:chart_class].nil?
      chart_class = 'StockChart' if chart_class == 'Stock'
      chart_class = 'Chart' if chart_class.nil?
      unless %w[Chart StockChart Map].include?(chart_class)
        raise 'chart_class must be selected as either chart, stock or map'
      end
      chart_class
    end

    def chart_hash_must_be_present
      @options[:chart] ||= {}
    end
  end
end
