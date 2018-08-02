def say(msg, &block)
  print "#{msg}..."

  if block_given?
      yield
    puts " Done."
  end
end

namespace :googlecharts do
  desc "Update google charts javascript dependent files, from latest Builds on google developers website"
  task :update => [:loader, :jspdf]
  sh "mkdir -p lib/assets/javascripts/googlecharts_js/"
  # FIXME: Updating jsapi is causing error when we run GoogleCharts in IRuby notebook.
  # refer: https://developers.google.com/chart/interactive/docs/basic_load_libs#update-library-loader-code
  # refer this issue: https://github.com/SciRuby/daru-view/issues/99
  #
  # task :jsapi do
  #   say "Grabbing Core from google jsapi codebase..." do
  #     sh "curl -# http://www.google.com/jsapi -L --compressed -o lib/daru/view/adapters/js/googlecharts_js/google_visualr.js"
  #   end
  # end

  task :loader do
    say "Grabbing loader.js from the google website..." do
      sh "curl -# http://www.gstatic.com/charts/loader.js -L --compressed -o lib/assets/javascripts/googlecharts_js/loader.js"
    end
  end

  task :jspdf do
     say "Grabbing jspdf.min.js from the cloudfare..." do
       sh "curl -# https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.5/jspdf.min.js -L --compressed -o lib/assets/javascripts/googlecharts_js/jspdf.min.js"
     end
   end
end
