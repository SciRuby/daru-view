# coding: utf-8

lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'daru/view/version'

Daru::View::DESCRIPTION = <<MSG
  Daru (Data Analysis in RUby) is a library for analysis, manipulation and
  visualization of data. Daru-view is for easy and interactive plotting in web
  application & IRuby notebook. It can work in frameworks e.g. Rails, Sinatra,
   Nanoc and hopefully in others too.
MSG

Gem::Specification.new do |spec|
  spec.name          = 'daru-view'
  spec.version       = Daru::View::VERSION
  spec.authors       = ['Shekhar Prasad Rajak']
  spec.email         = ['shekharrajak@live.com']

  spec.summary       = 'Plugin gem to Data Analysis in RUby(Daru) for visualisation of data'
  spec.description   = Daru::View::DESCRIPTION
  spec.homepage      = 'https://github.com/Shekharrajak/daru-view'
  spec.license       = 'MIT'
  spec.require_paths = ['lib']
  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = ['daru-view']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'pry'

  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rubocop'

  # fetching latest gem from the Gemfile
  spec.add_runtime_dependency 'google_visualr'
  spec.add_runtime_dependency 'lazy_high_charts'
  spec.add_runtime_dependency 'daru'
  spec.add_runtime_dependency 'nyaplot'
  spec.add_runtime_dependency 'daru-data_tables'

  # lazy_high_charts dependency
  spec.add_runtime_dependency 'actionview'

  # build gem and release it on rubygems
  spec.add_development_dependency 'rubygems-tasks'

  # gem for CLI
  spec.add_runtime_dependency 'thor'
end
