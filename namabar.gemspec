# frozen_string_literal: true

require_relative 'lib/namabar/version'

Gem::Specification.new do |spec|
  spec.name          = 'namabar'
  spec.version       = Namabar::VERSION
  spec.authors       = ['Muhammad Nawzad']
  spec.email         = ['hama127n@gmail.com']

  spec.summary       = 'Ruby SDK for Namabar OTP verification and messaging API'
  spec.description   = 'A lightweight Ruby SDK providing HTTParty-based client with type definitions for the Namabar OTP verification and messaging platform.'
  spec.homepage      = 'https://github.com/muhammadnawzad/namabar'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']       = spec.homepage
  spec.metadata['changelog_uri']      = 'https://github.com/muhammadnawzad/namabar/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri']  = 'https://rubydoc.info/gems/namabar'
  spec.metadata['bug_tracker_uri']    = 'https://github.com/muhammadnawzad/namabar/issues'
  spec.metadata['allowed_push_host']  = 'https://rubygems.org'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:(?:test|spec|features|helpers)/|\.(?:git|github|DS_Store))})
    end
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'httparty', '~> 0.2', '>= 0.2.0'
end
