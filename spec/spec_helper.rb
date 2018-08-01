require 'rspec'
require 'simplecov'
require 'daru/view'
require 'daru/data_tables'
require 'daru'
require 'coveralls'
require 'simplecov-console'

# Configure Rails Environment
# these lines are needed when spec/dummy_rails will be created
# ENV["RAILS_ENV"] = "test"
# require File.expand_path("dummy_rails/config/environment.rb",  __dir__)

Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::Console,
    # Want a nice code coverage website? Uncomment this next line!
    # SimpleCov::Formatter::HTMLFormatter
  ]
)
SimpleCov.start
