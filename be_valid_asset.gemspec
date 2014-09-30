# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'be_valid_asset/version'

Gem::Specification.new do |gem|
  gem.name          = "be_valid_asset"
  gem.version       = BeValidAsset::VERSION
  gem.authors       = ["Alex Tomlins", "Attila Gyorffy", "Ben Brinckerhoff", "Jolyon Pawlyn", "Sebastian de Castelberg", "Zubair Chaudary", "Murray Steele"]
  gem.email         = ["github@unboxedconsulting.com"]
  gem.description   = %q{Provides be_valid_markup, be_valid_css and be_valid_feed matchers for RSpec controller and view tests.}
  gem.summary       = %q{Markup and asset validation for RSpec}
  gem.homepage      = "http://github.com/unboxed/be_valid_asset"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency('rspec')
end
