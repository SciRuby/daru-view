source 'https://rubygems.org'

# Specify your gem's dependencies in daru-view.gemspec
gemspec

# if the .gemspec in this git repo doesn't match the version required by this
# gem's .gemspec, bundler will print an error
gem "daru", git: 'https://github.com/SciRuby/daru.git'
gem "nyaplot", git: 'https://github.com/SciRuby/nyaplot.git'
gem 'google_visualr', git: 'https://github.com/winston/google_visualr.git'

gem 'data_tables', git: 'https://github.com/Shekharrajak/data_tables.git'
# FixMe: if below line is not added, then we get uninitialized rails error, when we
# do bundle console. I don't know the reason. (it must be added with
# data_tables, above line)
gem 'rails'