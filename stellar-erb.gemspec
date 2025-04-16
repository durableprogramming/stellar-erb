# frozen_string_literal: true

require_relative "lib/stellar/erb/version"

Gem::Specification.new do |spec|
  spec.name = "stellar-erb"
  spec.version = Stellar::Erb::VERSION
  spec.authors = ["Durable Programming, LLC"]
  spec.email = ["djberube@durableprogramming.com"]

  spec.summary = "A safe, easy to use wrapper for ERB views outside of Rails"
  spec.description = "Stellar::Erb provides a method for reading .erb files from disk and rendering them to strings, passing arguments, and catching errors with correct backtraces and context."
  spec.homepage = "https://github.com/durableprogramming/stellar-erb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{bin,lib}/**/*") + %w[LICENSE README.md CHANGELOG.md]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "erb", "~> 4.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
