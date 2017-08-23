require 'rspec'
require 'simplecov'
require 'daru/view'
require 'daru'
# require 'nyaplot'

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy_rails/config/environment.rb",  __FILE__)
