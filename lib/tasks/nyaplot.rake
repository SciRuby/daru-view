def say(msg, &block)
  print "#{msg}..."

  if block_given?
      yield
    puts " Done."
  end
end

namespace :nyaplot do
  desc "Update nyaplot.js from latest Builds on Nyaplotjs github repo and d3.js website"
  task :update => [:nyaplot, :d3]
  task :nyaplot do
    say "Grabbing Core from Nyaplotjs codebase..." do
      # TODO get the nyaplot js file
    end
  end

  task :d3 do
    say "Grabbing Highcharts Stock JS from Upstream..." do
      # TODO : get the d3 and d3-downloaded
    end
  end

end
