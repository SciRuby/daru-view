require 'daru/view/constants'

module LazyHighCharts
  # generate initializing code
  def self.generate_init_code(dependent_js)
    js_dir = File.expand_path('../js/highcharts_js', __dir__)
    path = File.expand_path('../../templates/highcharts/init.inline.js.erb', __dir__)
    template = File.read(path)
    ERB.new(template).result(binding)
  end

  # Enable to show plots on IRuby notebook
  def self.init_iruby(
    dependent_js=HIGHCHARTS_DEPENDENCIES
  )
    # TODO: include highstock.js for highstock and modules/*.js files for
    # exporting and getting data from various source like csv files etc.
    #
    # Highstock.js includes the highcharts.js, so only one of them required.
    # see: https://www.highcharts.com/errors/16
    #
    # Using Highmaps as a plugin for HighCharts so using map.js instead of
    # highmaps.js
    #
    # , 'modules/exporting.js' : for the exporting button
    # data.js for getting data as csv or html table.
    # 'highcharts-more.js' : for arearange and some other chart type
    # Note: Don't reorder the dependent_js elements. It must be loaded in
    # the same sequence. Otherwise some of the JS overlap and doesn't work.
    js = generate_init_code(dependent_js)
    IRuby.display(IRuby.javascript(js))
  end
end
