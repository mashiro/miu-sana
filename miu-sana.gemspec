# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'miu/nodes/sana/version'

Gem::Specification.new do |spec|
  spec.name          = 'miu-sana'
  spec.version       = Miu::Nodes::Sana::VERSION
  spec.authors       = ['mashiro']
  spec.email         = ['mail@mashiro.org']
  spec.description   = %q{Logging node for miu}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/yuijo/miu-sana'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'miu', '>= 0.2.2'
  spec.add_dependency 'miu-rpc', '>= 0.0.2'
  spec.add_dependency 'rroonga', '>= 3.0.1'
  spec.add_dependency 'multi_json', '>= 1.7.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
