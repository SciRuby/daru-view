def say(msg, &block)
  print "#{msg}..."

  if block_given?
      yield
    puts " Done."
  end
end

namespace :googlecharts do
  desc "Update google charts javascript dependent files, from latest Builds on google developers website"
  task :update => [:loader, :jspdf, :cloudformatter]
  sh "mkdir -p lib/daru/view/adapters/js/googlecharts_js/"
  # FIXME: Updating jsapi is causing error in IRuby notebook and Googlecharts do not work.
  # task :jsapi do
  #   say "Grabbing Core from google jsapi codebase..." do
  #     sh "curl -# http://www.google.com/jsapi -L --compressed -o lib/daru/view/adapters/js/googlecharts_js/google_visualr.js"
  #   end
  # end

  task :loader do
    say "Grabbing loader.js from the google website..." do
      sh "curl -# http://www.gstatic.com/charts/loader.js -L --compressed -o lib/daru/view/adapters/js/googlecharts_js/loader.js"
    end
  end

  task :jspdf do
    say "Grabbing jspdf.min.js from the cloudfare..." do
      sh "curl -# https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.5/jspdf.min.js -L --compressed -o lib/daru/view/adapters/js/googlecharts_js/jspdf.min.js"
    end
  end

  task :cloudformatter do
    say "Grabbing jspdf.min.js from the cloudfare..." do
      sh "curl -# http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js -L --compressed -o lib/daru/view/adapters/js/googlecharts_js/jquery.min.js"
      sh "curl -# http://www.cloudformatter.com/Resources/Pages/CSS2Pdf/Script/xepOnline.jqPlugin.js -L --compressed -o lib/daru/view/adapters/js/googlecharts_js/xepOnline.jqPlugin.js"
    end
  end
end
