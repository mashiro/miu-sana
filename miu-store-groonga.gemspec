# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'miu-store-groonga/version'

Gem::Specification.new do |gem|
  gem.name          = "miu-store-groonga"
  gem.version       = Miu::Store::Groonga::VERSION
  gem.authors       = ["mashiro"]
  gem.email         = ["mail@mashiro.org"]
  gem.description   = %q{miu store groonga}
  gem.summary       = %q{miu store groonga}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'miu'
  gem.add_dependency 'rroonga'

  gem.add_development_dependency 'rake'
end
