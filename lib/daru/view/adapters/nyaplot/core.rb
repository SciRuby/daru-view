require 'erb'

lib_path = File.dirname(__FILE__)

module Nyaplot
	# generate initializing code
	def Nyaplot.generate_init_script
		init = Nyaplot.generate_init_code
		path = File.expand_path("#{lib_path}/daru/view/templates/nyaplot/init_script.erb", __FILE__)
		template = File.read(path)
		ERB.new(template).result(binding)
	end
end
