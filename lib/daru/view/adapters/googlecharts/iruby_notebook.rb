module GoogleVisualr
  # generate initializing code
  def self.generate_init_code(dependent_js)
    js_dir = File.expand_path('../js/googlecharts_js', __dir__)
    path = File.expand_path('../../templates/googlecharts/init.inline.js.erb', __dir__)
    template = File.read(path)
    ERB.new(template).result(binding)
  end

  # Enable to show plots on IRuby notebook
  def self.init_iruby(dependent_js=['google_visualr.js', 'loader.js', 'jspdf.min.js'])
    js = generate_init_code(dependent_js)
    IRuby.display(IRuby.javascript(js))
  end
end
