require_relative 'layout_helper_iruby'
require_relative 'iruby_notebook'
require 'daru/view/constants'

module LazyHighCharts
  # Loads the dependent javascript required
  #
  # @param [Array] dependent js files required
  # @return [String] js code of the dependent files
  def self.init_script(
    dependent_js=HIGHCHARTS_DEPENDENCIES_WEB
  )
    # Highstock is based on Highcharts, meaning it has all the core
    # functionality of Highcharts, plus some additional features. So
    # highstock.js contains highcharts.js .If highstock.js is removed then
    # add highchart.js to make chart script work.
    #
    # Note: Don't reorder the dependent_js elements. It must be loaded in
    # the same sequence. Otherwise some of the JS overlap and doesn't work.
    js = ''
    js << "\n<script type='text/javascript'>"
    js << LazyHighCharts.generate_init_code(dependent_js)
    js << "\n</script>"
    js
  end

  # Loads the dependent css required in styled mode
  #
  # @param [Array] dependent css files required
  # @return [String] CSS code of the dependent file(s)
  def self.init_css(
    dependent_css=HIGHCHARTS_DEPENDENCIES_CSS
  )
    css =  ''
    css << "\n<style type='text/css'>"
    css << LazyHighCharts.generate_init_code_css(dependent_css)
    css << "\n</style>"
    css
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
      script << high_chart_css(placeholder)
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
      script = high_chart_css(placeholder)
      script << high_chart_iruby(extract_chart_class, placeholder, self)
      script
    end

    # @param placeholder [String] ID of the div in which highchart has to
    #   rendered
    # @return [String] css code of the chart
    def high_chart_css(placeholder)
      # contains the css provided by the user as a String array
      css_data = options[:css].nil? ? '' : option.delete(:css)
      script = ''
      if css_data != ''
        script << '<style>'
        # Applying the css to chart div
        css_data.each do |css|
          script << '#' + placeholder + ' '
          script << css
        end
        script << '</style>'
      end
      script
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
    def extract_dependencies
      dep_js = []
      # Mapdata dependencies
      get_map_data_dependencies(dep_js)
      # Dependencies provided in modules option (of highcharts mainly
      #   like tilemap) by the user
      dep_js |= options.delete(:modules).map! { |js| "#{js}.js" } unless
      options[:modules].nil?
      dep_js
    end

    # @param dep_js [Array] JS dependencies required for drawing a map(mapdata)
    # @return [void] Appends the map data in dep_js
    def get_map_data_dependencies(dep_js)
      if !options[:chart_class].nil? && options[:chart_class].capitalize == 'Map' &&
         options[:chart] && options[:chart][:map]
        dep_js.push(options[:chart][:map].to_s)
        dep_js.map! { |js| "mapdata/#{js}.js" }
      end
    end

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
