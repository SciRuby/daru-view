require_relative 'layout_helper_iruby'
require_relative 'iruby_notebook'

module LazyHighCharts
  def self.init_script(
    dependent_js=['highstock.js', 'map.js', 'modules/exporting.js',
                  'highcharts-3d.js', 'modules/data.js']
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
      script = load_modules
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

    # @return the script of dependent modules of the chart
    def load_modules
      init = ''
      init = LazyHighCharts.init_script(options.delete(:modules).collect { |module_js| 'modules/' + module_js }) unless
      options[:modules].nil?
      init
    end

    def show_in_iruby(placeholder=random_canvas_id)
      # TODO : placeholder pass, in plot#div
      load_modules_iruby
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

    # @return load the dependent modules of the chart in IRuby notebook
    def load_modules_iruby
      LazyHighCharts.init_iruby(options.delete(:modules).collect { |module_js| 'modules/' + module_js }) unless
      options[:modules].nil?
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
