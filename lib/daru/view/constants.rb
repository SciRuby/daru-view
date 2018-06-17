# Dependent JS constants for web frameworks and IRuby notebook
HIGHSTOCK = 'highstock.js'.freeze
MAP = 'map.js'.freeze
EXPORTING = 'modules/exporting.js'.freeze
HIGHCHARTS_3D = 'highcharts-3d.js'.freeze
DATA = 'modules/data.js'.freeze
HIGHCHARTS_DEPENDENCIES = [HIGHSTOCK, MAP, EXPORTING, HIGHCHARTS_3D, DATA].freeze

# Dependent GoogleCharts JS constants for web frameworks and IRuby notebook
GOOGLECHARTS_DEPENDENCIES = ['google_visualr.js', 'loader.js'].freeze

# Regex pattern to match a valid URL
PATTERN_URL = Regexp.new(
  '^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$'
).freeze
