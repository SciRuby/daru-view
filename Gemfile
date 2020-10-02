source 'https://rubygems.org'

# Specify your gem's dependencies in daru-view.gemspec
gemspec

# Need the latest development version. Fetching it from the github repos.
# gem "daru", git: 'https://github.com/SciRuby/daru.git'
# TODO: later we will use the recent version of daru gem.
gem "daru", '0.2.0'
gem "nyaplot", git: 'https://github.com/SciRuby/nyaplot.git'
gem 'google_visualr', git: 'https://github.com/winston/google_visualr.git'

gem 'daru-data_tables', git: 'https://github.com/Shekharrajak/daru-data_tables.git'

group :test do
  gem 'coveralls', require: false
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'rubocop-performance'
end
