require_relative 'nyaplot/core.rb'
require 'daru'

module Daru
	module View
	  module Adapter
	    module NyaplotAdapter
	    	extend self
	      def init(data, options)
			    case
		      when data.is_a?(Daru::DataFrame)
		      	data.plot options
		      when data.is_a?(Daru::Vector)
		        data.plot options
		      when data.is_a?(Array)
		        Daru::View::Plot.new(Daru::DataFrame.new(data), options)
		      end
	      end
	  	end
	  end # Adapter end
  end
end
