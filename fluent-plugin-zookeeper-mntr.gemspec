# frozen_string_literal: true

require_relative "lib/fluent/plugin/zookeeper/mntr/version"

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-zookeeper-mntr"
  spec.version       = Fluent::Plugin::Zookeeper::Mntr::VERSION
  spec.authors       = ["Alex Scarborough"]
  spec.email         = ["alex@teak.io"]

  spec.summary       = "Reports output of mntr zookeeper command"
  spec.homepage      = "https://github.com/GoCarrot/fluent-plugin-zookeeper-mntr"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/GoCarrot/fluent-plugin-zookeeper-mntr"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|bin)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rake', ['>= 13.0.6']
  spec.add_development_dependency 'bundler', ['>= 2']
  spec.add_development_dependency 'test-unit', ['~> 3.5', '>= 3.5.3']

  spec.add_runtime_dependency 'fluentd', ['~> 1.0']
end
