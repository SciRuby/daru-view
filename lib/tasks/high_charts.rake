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
  task :update => [:core, :stock, :map]
  task :core do
    say "Grabbing Core from Highcharts codebase..." do
      sh "mkdir -p lib/daru/view/adapters/js/highcharts_js/modules/"
      sh "mkdir -p lib/daru/view/adapters/js/highcharts_js/adapters/"

      sh "curl -# http://code.highcharts.com/highcharts.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/highcharts.js"
      sh "curl -# http://code.highcharts.com/highcharts-more.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/highcharts-more.js"
      sh "curl -# http://code.highcharts.com/highcharts-3d.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/highcharts-3d.js"

      # Modules
      sh "curl -# http://code.highcharts.com/modules/accessibility.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/accessibility.js"
      sh "curl -# http://code.highcharts.com/modules/annotations.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/annotations.js"
      sh "curl -# http://code.highcharts.com/modules/boost.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/boost.js"
      sh "curl -# http://code.highcharts.com/modules/broken-axis.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/broken-axis.js"
      sh "curl -# http://code.highcharts.com/modules/canvas-tools.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/canvas-tools.js"
      sh "curl -# http://code.highcharts.com/modules/data.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/data.js"
      sh "curl -# http://code.highcharts.com/modules/exporting.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/exporting.js"
      sh "curl -# http://code.highcharts.com/modules/drilldown.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/drilldown.js"
      sh "curl -# http://code.highcharts.com/modules/funnel.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/funnel.js"
      sh "curl -# http://code.highcharts.com/modules/heatmap.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/heatmap.js"
      sh "curl -# http://code.highcharts.com/modules/histogram-bellcurve.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/histogram-bellcurve.js"
      sh "curl -# http://code.highcharts.com/modules/no-data-to-display.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/no-data-to-display.js"
      sh "curl -# http://code.highcharts.com/modules/offline-exporting.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/offline-exporting.js"
      sh "curl -# http://code.highcharts.com/modules/sankey.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/sankey.js"
      sh "curl -# http://code.highcharts.com/modules/solid-gauge.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/solid-gauge.js"
      sh "curl -# http://code.highcharts.com/modules/treemap.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/treemap.js"
      sh "curl -# http://code.highcharts.com/modules/tilemap.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/tilemap.js"
      sh "curl -# http://code.highcharts.com/modules/variwide.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/variwide.js"
      sh "curl -# http://code.highcharts.com/modules/vector.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/vector.js"
      sh "curl -# http://code.highcharts.com/modules/windbarb.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/modules/windbarb.js"

      sh "curl -# http://code.highcharts.com/adapters/mootools-adapter.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/adapters/mootools-adapter.js"
      sh "curl -# http://code.highcharts.com/adapters/prototype-adapter.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/adapters/prototype-adapter.js"
    end
  end

  task :stock do
    say "Grabbing Highcharts Stock JS from Upstream..." do

      sh "mkdir -p lib/daru/view/adapters/js/highcharts_js/stock/modules/"
      sh "mkdir -p lib/daru/view/adapters/js/highcharts_js/stock/adapters/"

      sh "curl -# http://code.highcharts.com/stock/highstock.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/highstock.js"
      sh "curl -# http://code.highcharts.com/stock/highcharts-more.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/stock/highcharts-more.js"
      sh "curl -# http://code.highcharts.com/stock/modules/exporting.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/stock/modules/exporting.js"
      sh "curl -# http://code.highcharts.com/stock/modules/funnel.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/stock/modules/funnel.js"
      sh "curl -# http://code.highcharts.com/stock/adapters/mootools-adapter.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/stock/adapters/mootools-adapter.js"
      sh "curl -# http://code.highcharts.com/stock/adapters/prototype-adapter.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/stock/adapters/prototype-adapter.js"
    end
  end

  task :map do
    say "Grabbing HighMaps JS from Upstream..." do

      sh "mkdir -p lib/daru/view/adapters/js/highcharts_js/mapdata/countries/"
      sh "mkdir -p lib/daru/view/adapters/js/highcharts_js/mapdata/custom/"

      countries_folders = ['in', 'us', 'gb', 'af', 'au', 'bd', 'be', 'ca', 'cn', 'fr']
      countries_folders.each do |country|
        sh "mkdir -p lib/daru/view/adapters/js/highcharts_js/mapdata/countries/" + country
      end
      sh "mkdir -p lib/daru/view/adapters/js/highcharts_js/mapdata/countries/in/custom"

      custom_areas = ['europe.js', 'world.js']
      custom_areas.each do |custom_area|
        sh "curl -# http://code.highcharts.com/mapdata/custom/" + custom_area + " -L --compressed -o lib/daru/view/adapters/js/highcharts_js/mapdata/custom/" + custom_area
      end

      countries_dependencies = ['in-all.js', 'us-all.js', 'gb-all.js', 'af-all.js', 'au-all.js', 'bd-all.js', 'be-all.js', 'ca-all.js', 'cn-all.js', 'fr-all.js']
      countries_dependencies.each do |dep|
        sh "curl -# http://code.highcharts.com/mapdata/countries/" + dep[0,2] + "/" + dep + " -L --compressed -o lib/daru/view/adapters/js/highcharts_js/mapdata/countries/"  + dep[0,2] + "/" + dep
      end

      sh "curl -# http://code.highcharts.com/maps/modules/map.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/map.js"
      sh "curl -# http://code.highcharts.com/mapdata/countries/in/custom/in-all-andaman-and-nicobar.js -L --compressed -o lib/daru/view/adapters/js/highcharts_js/mapdata/countries/in/custom/in-all-andaman-and-nicobar.js"
    end  
  end

end
