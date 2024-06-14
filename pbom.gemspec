# frozen_string_literal: true

require_relative "lib/pbom/version"

Gem::Specification.new do |spec|
  spec.name = "pbom"
  spec.version = Pbom::VERSION
  spec.authors = ["Andrew Nesbitt"]
  spec.email = ["andrewnez@gmail.com"]

  spec.summary = "Generate a package bill of materials from a project"
  spec.description = "Generate a package bill of materials from a project"
  spec.homepage = "https://github.com/andrew/PBOM"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/andrew/PBOM"
  spec.metadata["changelog_uri"] = "https://github.com/andrew/PBOM/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) } + ["cli"]
  spec.require_paths = ["lib"]

  spec.add_dependency 'packageurl-ruby'
  spec.add_dependency 'json'
  spec.add_dependency 'faraday'
end
