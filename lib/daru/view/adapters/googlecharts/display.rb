require 'securerandom'
require 'erb'
require_relative 'data_table_iruby'

module GoogleVisualr
  def self.init_script(
    dependent_js=['google_visualr.js', 'loader.js']
  )
    js =  ''
    js << "\n<script type='text/javascript'>"
    js << LazyHighCharts.generate_init_code(dependent_js)
    js << "\n</script>"
    js
  end

  module Display
    def show_script(dom=SecureRandom.uuid, options={})
      script_tag = options.fetch(:script_tag) { true }
      if script_tag
        # if it is data table
        if is_a?(GoogleVisualr::DataTable)
          to_js_full_script(dom)
        else
          to_js(dom)
        end
      else
        html = ''
        html << load_js(dom)
        html << draw_js(dom)
        html
      end
    end

    def to_html(id=nil, options={})
      path = File.expand_path('../../../templates/googlecharts/chart_div.erb', __FILE__)
      template = File.read(path)
      id ||= SecureRandom.uuid
      chart_script = show_script(id, script_tag: false)
      ERB.new(template).result(binding)
    end

    def show_in_iruby(dom=SecureRandom.uuid)
      IRuby.html(to_html(dom))
    end
  end

  class DataTable
    include Display
  end
end
