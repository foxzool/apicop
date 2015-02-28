# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apicop/version'

Gem::Specification.new do |spec|
  spec.name = "APICop"
  spec.version = APICop::VERSION
  spec.authors = ["ZoOL"]
  spec.email = ["zhooul@gmail.com"]

  spec.summary = %q{ a REST like oauth2 api server }
  spec.description = %q{  Authorization Server solution and Resource Server Guard solution}
  spec.homepage = "https://github.com/foxzool/apicop"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'grape'
  spec.add_runtime_dependency 'warden', '~> 1.0'
  spec.add_runtime_dependency "rack", ">= 1.1"
  spec.add_runtime_dependency "multi_json", ">= 1.3.6"
  spec.add_runtime_dependency "httpclient", ">= 2.4"
  spec.add_runtime_dependency "activesupport", ">= 2.3"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
