
require 'nyaplot'
require_relative 'nyaplot/iruby_notebook'

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
          when data.is_a?(Daru::Vector)
            data.plot options
          else
            # TODO: add more cases e.g. Array of rows
            raise ArgumentError, "For Nyaplot Library, data must be in Daru::Vector or Daru::DataFrame.\n You can change the plotting library using the code : \n ` Daru::View.plotting_library = :highcharts` or other library."
          end
        end

        def export_html_file(plot, path)
          plot.export_html path
        end

        def show_in_iruby(plot)
          plot.show
        end

        def init_script
          Nyaplot.init_script
        end

        def generate_body(plot)
          plot.to_iruby[1]
        end

        def init_iruby
          Nyaplot.init_iruby
        end

      end
    end # Adapter end
  end
end
