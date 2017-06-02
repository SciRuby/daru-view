require_relative 'nyaplot/core.rb'
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
            return data.plot options
          when data.is_a?(Daru::Vector)
            return data.plot options
          else
            # TODO: add more cases e.g. Array of rows
            ArgumentError
          end
        end

        def init_script
          init = Nyaplot.generate_init_code
          path = File.expand_path("../templates/nyaplot/init_script.erb", __FILE__)
          template = File.read(path)
          ERB.new(template).result(binding)
        end

        def generate_body(plot)
          plot.to_iruby[1]
        end

        def export_html(plot, path="./plot.html")
          plot.export_html
        end

      end
    end # Adapter end
  end
end
