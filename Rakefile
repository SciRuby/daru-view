require "bundler/gem_tasks"

require 'bundler/setup'
require 'rubygems/tasks'
Gem::Tasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc 'Default: run unit specs.'
task :default => %w[spec rubocop]

require 'coveralls/rake/task'
Coveralls::RakeTask.new

import 'lib/tasks/high_charts.rake'
import 'lib/tasks/nyaplot.rake'
import 'lib/tasks/google_charts.rake'

# TODO: add Nyaplot
task :update_all => ["googlecharts:update", "highcharts:update"]

