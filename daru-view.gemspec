# coding: utf-8

lib = File.expand_path('../lib', __FILE__)

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
  spec.authors       = ['shekharrajak']
  spec.email         = ['shekharstudy@ymail.com']

  spec.summary       = 'Plugin gem to Data Analysis in RUby(Daru) for visualisation of data'
  spec.description   = Daru::View::DESCRIPTION
  spec.homepage      = 'http://shekharrajak.github.io/daru-view'
  spec.license       = 'MIT'
  spec.require_paths = ['lib']
  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'pry'

  # pry-byebug depends on byebug. It need r header files for ruby.
  # For Debian, and other distributions using Debian style packaging the ruby development headers are installed by:

  # sudo apt-get install ruby-dev
  # For Ubuntu the ruby development headers are installed by:

  # sudo apt-get install ruby-all-dev
  # If you are using a earlier version of ruby (such as 2.2), then you will need to run:

  # sudo apt-get install ruby2.2-dev
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rubocop'

  spec.add_runtime_dependency 'google_visualr'
  spec.add_runtime_dependency 'lazy_high_charts'
  spec.add_runtime_dependency 'daru' # use from the Gemfile
  spec.add_runtime_dependency 'nyaplot'
  spec.add_runtime_dependency 'daru-data_tables'

  # lazy_high_charts dependency
  spec.add_runtime_dependency 'actionview'

  # spec.add_development_dependency "iruby"
end

