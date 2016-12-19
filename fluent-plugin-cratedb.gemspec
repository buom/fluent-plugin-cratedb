# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-cratedb"
  spec.version       = File.read('VERSION').strip
  spec.authors       = ["buom"]
  spec.email         = ["me@buom.io"]

  spec.summary       = %q{A plugin for Fluentd}
  spec.description   = %q{Fluent Output Plugin for CrateDB (http://crate.io)}
  spec.homepage      = "https://github.com/buom/fluent-plugin-cratedb"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|bin)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency "crate_ruby", "~> 0.0.8"
  spec.add_runtime_dependency "fluentd", "~> 0.12.0"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
