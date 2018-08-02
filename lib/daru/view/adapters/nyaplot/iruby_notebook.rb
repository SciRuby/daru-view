module Nyaplot
  # generate initializing code
  def self.generate_init_code_offline(dependent_js)
    js_dir = File.expand_path(
      '../../../../../vendor/assets/javascripts/nyaplot', __dir__
    )
    path = File.expand_path(
      '../../templates/nyaplot/init.inline.js.erb', __dir__
    )
    template = File.read(path)
    ERB.new(template).result(binding)
  end

  # generate initializing code
  def self.generate_init_code_online
    # TODO : better than present Nyaplot.generate_init_code
  end

  # Enable to show plots on IRuby notebook
  def self.init_iruby(*)
    #
    # dependent_js=['d3.min.js', 'd3-downloadable.js', 'nyaplot.js']
    js = generate_init_code
    IRuby.display(IRuby.javascript(js))
  end
end
