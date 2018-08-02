# using code from lazy _high_charts gem with some modification

def say(msg, &block)
  print "#{msg}..."

  if block_given?
      yield
    puts " Done."
  end
end

namespace :highcharts do
  desc "Update highcharts.js from latest Builds on Highcharts codebase: http://code.highcharts.com/"
  task :update => [:core, :stock, :map, :css]
  task :core do
    say "Grabbing Core from Highcharts codebase..." do
      sh "mkdir -p vendor/assets/javascripts/highcharts/modules/"
      sh "mkdir -p vendor/assets/javascripts/highcharts/adapters/"

      sh "curl -# http://code.highcharts.com/highcharts.js -L --compressed -o vendor/assets/javascripts/highcharts/highcharts.js"
      sh "curl -# http://code.highcharts.com/highcharts-more.js -L --compressed -o vendor/assets/javascripts/highcharts/highcharts-more.js"
      sh "curl -# http://code.highcharts.com/highcharts-3d.js -L --compressed -o vendor/assets/javascripts/highcharts/highcharts-3d.js"

      modules = ['accessibility', 'annotations', 'boost', 'broken-axis',
                 'canvas-tools', 'data', 'exporting', 'drilldown', 'funnel',
                 'heatmap', 'histogram-bellcurve', 'no-data-to-display',
                 'offline-exporting', 'sankey', 'solid-gauge', 'treemap',
                 'tilemap', 'variwide', 'vector', 'windbarb']

      modules.each do |modul|
        sh "curl -# http://code.highcharts.com/modules/" + modul + ".js -L --compressed -o vendor/assets/javascripts/highcharts/modules/" + modul + ".js"
      end
      sh "curl -# http://code.highcharts.com/adapters/mootools-adapter.js -L --compressed -o vendor/assets/javascripts/highcharts/adapters/mootools-adapter.js"
      sh "curl -# http://code.highcharts.com/adapters/prototype-adapter.js -L --compressed -o vendor/assets/javascripts/highcharts/adapters/prototype-adapter.js"
    end
  end

  task :stock do
    say "Grabbing Highcharts Stock JS from Upstream..." do

      sh "mkdir -p vendor/assets/javascripts/highcharts/stock/modules/"
      sh "mkdir -p vendor/assets/javascripts/highcharts/stock/adapters/"
      sh "mkdir -p vendor/assets/javascripts/highcharts/js/"

      sh "curl -# http://code.highcharts.com/stock/highstock.js -L --compressed -o vendor/assets/javascripts/highcharts/highstock.js"
      sh "curl -# http://code.highcharts.com/stock/js/highstock.js -L --compressed -o vendor/assets/javascripts/highcharts/js/highstock.js"
      sh "curl -# http://code.highcharts.com/stock/highcharts-more.js -L --compressed -o vendor/assets/javascripts/highcharts/stock/highcharts-more.js"
      sh "curl -# http://code.highcharts.com/stock/modules/exporting.js -L --compressed -o vendor/assets/javascripts/highcharts/stock/modules/exporting.js"
      sh "curl -# http://code.highcharts.com/stock/modules/funnel.js -L --compressed -o vendor/assets/javascripts/highcharts/stock/modules/funnel.js"
      sh "curl -# http://code.highcharts.com/stock/adapters/mootools-adapter.js -L --compressed -o vendor/assets/javascripts/highcharts/stock/adapters/mootools-adapter.js"
      sh "curl -# http://code.highcharts.com/stock/adapters/prototype-adapter.js -L --compressed -o vendor/assets/javascripts/highcharts/stock/adapters/prototype-adapter.js"
    end
  end

  task :map do
    say "Grabbing HighMaps JS from Upstream..." do

      sh "mkdir -p vendor/assets/javascripts/highcharts/mapdata/countries/"
      sh "mkdir -p vendor/assets/javascripts/highcharts/mapdata/custom/"

      countries = ['ad', 'ae', 'af', 'ag', 'al', 'am', 'ao', 'ar', 'as', 'at',
                   'au', 'az', 'ba', 'bb', 'bd', 'be', 'bf', 'bg', 'bh', 'bi',
                   'bj', 'bn', 'bo', 'br', 'bs', 'bt', 'bw', 'by', 'bz', 'ca',
                   'cf', 'ci', 'cg', 'ch', 'ck', 'cl', 'cm', 'cn', 'co', 'cr',
                   'cu', 'cv', 'cy', 'cz', 'de', 'dj', 'dk', 'dm', 'do', 'dz',
                   'ec', 'ee', 'eg', 'eh', 'er', 'es', 'et', 'fi', 'fj', 'fo',
                   'fr', 'ga', 'gb', 'gd', 'ge', 'gh', 'gl', 'gm', 'gn', 'gq',
                   'gr', 'gt', 'gu', 'gw', 'gy', 'hn', 'hr', 'ht', 'hu', 'id',
                   'ie', 'il', 'in', 'iq', 'ir', 'is', 'it', 'jm', 'jo', 'jp',
                   'ke', 'kh', 'kg', 'km', 'kn', 'kp', 'kr', 'kv', 'kw', 'kz',
                   'la', 'lb', 'lc', 'li', 'lk', 'lr', 'ls', 'lt', 'lu', 'lv',
                   'ly', 'ma', 'mc', 'md', 'me', 'mg', 'mk', 'ml', 'mm', 'mn',
                   'mp', 'mr', 'mt', 'mu', 'mw', 'mx', 'my', 'mz', 'na', 'nc',
                   'ne', 'ng', 'ni', 'nl', 'no', 'np', 'nr', 'nz', 'om', 'pa',
                   'pe', 'pg', 'ph', 'pk', 'pl', 'pr', 'pt', 'pw', 'py', 'qa',
                   'ro', 'rs', 'ru', 'rw', 'sa', 'sb', 'sc', 'sd', 'se', 'sg',
                   'si', 'sk', 'sl', 'sm', 'sn', 'so', 'sr', 'ss', 'st', 'sx',
                   'sy', 'sz', 'tj', 'tg', 'th', 'tm', 'tn', 'tr', 'tt', 'tw',
                   'tz', 'ua', 'ug', 'us', 'uy', 'uz', 'vc', 've', 'vi', 'vn',
                   'vu', 'wf', 'ws', 'ye', 'za', 'zm', 'zw']
      countries.each do |country|
        sh "mkdir -p vendor/assets/javascripts/highcharts/mapdata/countries/" + country
        sh "curl -# http://code.highcharts.com/mapdata/countries/" + country + "/" + country + "-all.js" + " -L --compressed -o vendor/assets/javascripts/highcharts/mapdata/countries/" + country + "/" + country + "-all.js"
      end
      sh "mkdir -p vendor/assets/javascripts/highcharts/mapdata/countries/in/custom"

      custom_areas = ['africa', 'antarctica', 'asia', 'benelux',
                      'british-isles', 'british-isles-all', 'usa-and-canada',
                      'central-america', 'europe', 'european-union',
                      'middle-east', 'nordic-countries',
                      'nordic-countries-core', 'north-america',
                      'north-america-no-central', 'nato', 'oceania',
                      'scandinavia', 'south-america', 'world-continents',
                      'world-palestine-highres', 'world-palestine-lowres',
                      'world-palestine', 'world-eckert3', 'world',
                      'world-robinson']
      custom_areas.each do |custom_area|
        sh "curl -# http://code.highcharts.com/mapdata/custom/" + custom_area + ".js -L --compressed -o vendor/assets/javascripts/highcharts/mapdata/custom/" + custom_area + ".js"
      end

      sh "curl -# http://code.highcharts.com/maps/modules/map.js -L --compressed -o vendor/assets/javascripts/highcharts/map.js"
      sh "curl -# http://code.highcharts.com/mapdata/countries/in/custom/in-all-andaman-and-nicobar.js -L --compressed -o vendor/assets/javascripts/highcharts/mapdata/countries/in/custom/in-all-andaman-and-nicobar.js"
      sh "curl -# http://code.highcharts.com/maps/js/modules/map.js -L --compressed -o vendor/assets/javascripts/highcharts/js/map.js"
    end  
  end

  task :css do
    say "Grabbing CSS of HighCharts from Upstream..." do
      sh "mkdir -p vendor/assets/stylesheets/highcharts/"

      sh "curl -# http://code.highcharts.com/css/highcharts.css -L --compressed -o vendor/assets/stylesheets/highcharts/highcharts.css"
    end
  end
end
