# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gems/version"

Gem::Specification.new do |spec|
  spec.name          = "danger-gems"
  spec.version       = Gems::VERSION
  spec.authors       = ["John DeSilva"]
  spec.email         = ["john@aesthetikx.info"]
  spec.description   = "A short description of danger-gems."
  spec.summary       = "A longer description of danger-gems."
  spec.homepage      = "https://github.com/Aesthetikx/danger-gems"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.required_ruby_version = ">= 2.7"
  spec.add_runtime_dependency "danger-plugin-api", "~> 1.0"
  spec.add_runtime_dependency "nokogiri", "~> 1.0"
  spec.add_runtime_dependency "open-uri"
end
