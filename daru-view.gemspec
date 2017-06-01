# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'daru/view/version'

Daru::View::DESCRIPTION = <<MSG
Daru (Data Analysis in RUby) is a library for analysis, manipulation and visualization
of data. Daru-view is for easy and interactive plotting in web application & IRuby notebook. It can work in frameworks e.g. Rails, Sinatra, Nanoc and hopefully in others too.
MSG

Gem::Specification.new do |spec|
  spec.name          = 'daru-view'
  spec.version       = Daru::View::VERSION
  spec.authors       = ["shekharrajak"]
  spec.email         = ["shekharstudy@ymail.com"]

  spec.summary       = %q{Plugin gem to Data Analysis in RUby(Daru) for visualisation of data}
  spec.description   = Daru::View::DESCRIPTION
  spec.homepage      = "http://github.com/shekharrajak/daru-view"
  spec.license       = "MIT"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_development_dependency "daru", "~> 0.1.5"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'pry-byebug'
end

