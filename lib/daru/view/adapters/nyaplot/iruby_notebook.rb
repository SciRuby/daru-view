module Nyaplot
  # generate initializing code
  def self.generate_init_code_offline(dependent_js)
    js_dir = File.expand_path("../../js/nyaplot_js", __FILE__)
    path = File.expand_path("../../../templates/nyaplot/init.inline.js.erb", __FILE__)
    template = File.read(path)
    ERB.new(template).result(binding)
  end

  # generate initializing code
  def self.generate_init_code_online
    # todo : better than present Nyaplot.generate_init_code
  end

  # Enable to show plots on IRuby notebook
  def self.init_iruby(
    dependent_js=['d3.min.js', 'd3-downloadable.js', 'nyaplot.js']
  )
    # todo: include highstock.js for highstock and modules/*.js files for
    # exporting and getting data from various source like csv files etc.
    #
    # Highstock.js includes the highcharts.js, so only one of them required.
    # see: https://www.highcharts.com/errors/16
    js = self.generate_init_code
    IRuby.display(IRuby.javascript(js))
  end
end
