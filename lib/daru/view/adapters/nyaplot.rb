
require 'daru'
require 'nyaplot'

module Daru
  module View
    module Adapter
      module NyaplotAdapter
        extend self
        def init(data, options)
          case
          when data.is_a?(Daru::DataFrame)
            # define method called plot_obj in daru/plotting/../NyaplotLibrary
            # to get the plot object.
            data.plot options
            return data.plot_obj
          when data.is_a?(Daru::Vector)
            data.plot options
            return data.plot_obj
          else
            # TODO: add more cases e.g. Array of rows
            ArgumentError
          end
        end

        def init_script
          init = Nyaplot.generate_init_code
          path = File.expand_path("../../templates/nyaplot/init_script.erb", __FILE__)
          template = File.read(path)
          ERB.new(template).result(binding).html_safe
        end

        def generate_body(plot)
          plot.to_iruby[1].html_safe
        end

        def export_html_file(plot, path="./plot.html")
          plot.export_html path
        end

        def show_iruby(plot)
          plot.show
        end

      end
    end # Adapter end
  end
end
