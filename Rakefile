require "bundler/gem_tasks"

desc 'Default: run unit specs.'
task :default => :spec


import 'lib/tasks/high_charts.rake'
import 'lib/tasks/nyaplot.rake'
import 'lib/tasks/google_charts.rake'

# TODO: add Nyaplot
task :update_all => ["googlecharts:update", "highcharts:update"]
