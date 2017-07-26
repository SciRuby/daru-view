require_relative 'layout_helper_iruby'
require_relative 'iruby_notebook'

module LazyHighCharts
  def self.init_script(
    dependent_js=['highstock.js', 'highcharts-3d.js', 'modules/data.js',
      'modules/exporting.js']
  )
    # Highstock is based on Highcharts, meaning it has all the core
    # functionality of Highcharts, plus some additional features. So
    # highstock.js contains highcharts.js .If highstock.js is removed then
    # add highchart.js to make chart script work.
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
      high_chart(placeholder, self)
    end

    def show_in_iruby(placeholder=random_canvas_id)
      # TODO : placeholder pass, in plot#div
      chart_hash_must_be_present
      IRuby.html high_chart_iruby(placeholder, self)
    end

    # This method is not needed if `to_html` generates the same code. Here
    # `to_html` generates the code with `onload`, so there is need of
    # `high_chart_iruby` which doesn't use `onload` in chart script.
    def to_html_iruby(placeholder=random_canvas_id)
      # TODO : placeholder pass, in plot#div
      chart_hash_must_be_present
      high_chart_iruby(placeholder, self)
    end

    def chart_hash_must_be_present
      @options[:chart] ||= {}
    end
  end # class end
end
