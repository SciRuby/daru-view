def say(msg, &block)
  print "#{msg}..."

  if block_given?
      yield
    puts " Done."
  end
end

namespace :googlecharts do
  desc "Update google charts javascript dependent files, from latest Builds on google developers website"
  task :update => [:loader]
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
end
