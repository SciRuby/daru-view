require 'securerandom'
require 'erb'
require_relative 'display'
require_relative 'generate_javascript'
require 'daru/view/constants'

module GoogleVisualr
  def self.init_script(
    dependent_js=GOOGLECHARTS_DEPENDENCIES_WEB
  )
    js =  ''
    js << "\n<script type='text/javascript'>"
    js << GoogleVisualr.generate_init_code(dependent_js)
    js << "\n</script>"
    js
  end

  class DataTable
    include Display
    include GenerateJavascript
  end

  class BaseChart
    include Display
    include GenerateJavascript
  end
end
