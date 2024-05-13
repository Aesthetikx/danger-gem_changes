# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gem_changes/version"

Gem::Specification.new do |spec|
  spec.name          = "danger-gem_changes"
  spec.version       = GemChanges::VERSION
  spec.authors       = ["John DeSilva"]
  spec.email         = ["john@aesthetikx.info"]
  spec.description   = "A danger plugin for helping review gem depencency changes."
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/Aesthetikx/danger-gem_changes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["issue_tracker_uri"] = "#{spec.homepage}/issues"
  spec.required_ruby_version = ">= 3.1"
  spec.add_runtime_dependency "danger-plugin-api", "~> 1.0"
  spec.add_runtime_dependency "nokogiri", "~> 1.0"
end
