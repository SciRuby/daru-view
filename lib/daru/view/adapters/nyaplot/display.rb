module Nyaplot
  # dependent JS to include in head tag of the web application
  def self.init_script
    init = Nyaplot.generate_init_code
    path = File.expand_path('../../templates/nyaplot/init_script.erb', __dir__)
    template = File.read(path)
    ERB.new(template).result(binding)
  end
end
