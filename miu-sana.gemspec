# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'miu-sana/version'

Gem::Specification.new do |gem|
  gem.name          = "miu-sana"
  gem.version       = Miu::Sana::VERSION
  gem.authors       = ["mashiro"]
  gem.email         = ["mail@mashiro.org"]
  gem.description   = %q{miu logging plugin sana}
  gem.summary       = %q{miu logging plugin sana}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'miu'
  gem.add_dependency 'saorin'
  gem.add_dependency 'rroonga'
  gem.add_development_dependency 'rake'
end
