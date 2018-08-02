require 'daru/view/constants'

module GoogleVisualr
  # generate initializing code
  def self.generate_init_code(dependent_js)
    js_dir = File.expand_path(
      '../../../../assets/javascripts/googlecharts_js', __dir__
    )
    path = File.expand_path(
      '../../templates/googlecharts/init.inline.js.erb', __dir__
    )
    template = File.read(path)
    ERB.new(template).result(binding)
  end

  # Enable to show plots on IRuby notebook
  def self.init_iruby(dependent_js=GOOGLECHARTS_DEPENDENCIES_IRUBY)
    js = generate_init_code(dependent_js)
    IRuby.display(IRuby.javascript(js))
  end
end
