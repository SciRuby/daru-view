require 'securerandom'

module GoogleVisualr
  class DataTable
    # included to use `js_parameters` method
    include GoogleVisualr::ParamHelpers

    def initialize(options = {})
      @cols = Array.new
      @rows = Array.new

      @options = options
      unless options.empty?
        unless options[:cols].nil?

          cols = options[:cols]
          new_columns(cols)
        end

        unless options[:cols].nil?
          rows = options[:rows]
          rows.each do |row|
            add_row(row[:c])
          end
        end
      end
    end

    # Generates JavaScript and renders the Google Chart DataTable in the
    # final HTML output.
    #
    # Parameters:
    #  *div_id            [Required] The ID of the DIV element that the Google Chart DataTable should be rendered in.
    def to_js_full_script(element_id=SecureRandom.uuid)
      js =  ""
      js << "\n<script type='text/javascript'>"
      js << load_js(element_id)
      js << draw_js(element_id)
      js << "\n</script>"
      js
    end

    def chart_function_name(element_id)
      "draw_#{element_id.gsub('-', '_')}"
    end

    def google_table_version
      "1.0".freeze
    end

    def package_name
      'table'
    end

    # Generates JavaScript for loading the appropriate Google Visualization package, with callback to render chart.
    #
    # Parameters:
    #  *div_id            [Required] The ID of the DIV element that the Google Chart should be rendered in.
    def load_js(element_id)
      "\n  google.load('visualization', #{google_table_version}, {packages: ['#{package_name}'], callback: #{chart_function_name(element_id)}});"
    end

    # Generates JavaScript function for rendering the chart.
    #
    # Parameters:
    #  *div_id            [Required] The ID of the DIV element that the Google Chart should be rendered in.
    def draw_js(element_id)
      js = ""
      js << "\n  function #{chart_function_name(element_id)}() {"
      js << "\n    #{self.to_js}"
      js << "\n    var table = new google.visualization.Table("
      js << "\n    document.getElementById('#{element_id}'));"
      js << "\n    table.draw(data_table, #{js_parameters(@options)});"
      js << "\n  };"
      js
    end
  end # class Datatable end
end