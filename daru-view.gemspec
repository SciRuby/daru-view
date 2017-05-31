# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daru/view/version'

Daru::View::DESCRIPTION = <<MSG
Daru (Data Analysis in RUby) is a library for analysis, manipulation and visualization
of data. Daru-view is for easy and interactive plotting in web application & IRuby notebook. It can work in frameworks e.g. Rails, Sinatra, Nanoc and hopefully in others too.
MSG

Gem::Specification.new do |spec|
  spec.name          = "daru-view"
  spec.version       = Daru::View::VERSION
  spec.authors       = ["shekharrajak"]
  spec.email         = ["shekharstudy@ymail.com"]

  spec.summary       = %q{Data visualization using Data Analysis in RUby(Daru)}
  spec.description   = Daru::View::DESCRIPTION
  spec.homepage      = "http://github.com/shekharrajak/daru-view"
  spec.license       = "something"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "iruby"
end
