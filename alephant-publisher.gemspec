# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alephant/publisher/version'

Gem::Specification.new do |spec|
  spec.name          = "alephant-publisher"
  spec.version       = Alephant::Publisher::VERSION
  spec.authors       = ["Integralist"]
  spec.email         = ["mark.mcdx@gmail.com"]
  spec.summary       = "Static publishing to S3 based on SQS messages"
  spec.description   = "Static publishing to S3 based on SQS messages"
  spec.homepage      = "https://github.com/BBC-News/alephant-publisher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-remote"
  spec.add_development_dependency "pry-nav"

  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'trollop'
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'aws-sdk', '~> 1.0'
  spec.add_runtime_dependency 'mustache', '>= 0.99.5'
  spec.add_runtime_dependency 'jsonpath'
  spec.add_runtime_dependency 'crimp'
  spec.add_runtime_dependency 'peach'
  spec.add_runtime_dependency 'i18n'
  spec.add_runtime_dependency 'mustache'
  spec.add_runtime_dependency 'hashie'
  spec.add_runtime_dependency 'alephant-support'
  spec.add_runtime_dependency 'alephant-sequencer'
  spec.add_runtime_dependency 'alephant-cache'
  spec.add_runtime_dependency 'alephant-logger'
  spec.add_runtime_dependency 'alephant-lookup'
  spec.add_runtime_dependency 'alephant-preview'
end
