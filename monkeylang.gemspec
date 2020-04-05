# frozen_string_literal: true

require_relative 'lib/monkeylang/version'

Gem::Specification.new do |spec|
  spec.name          = 'monkeylang'
  spec.version       = Monkeylang::VERSION
  spec.authors       = ['Farid Zakaria']
  spec.email         = ['farid.m.zakaria@gmail.com']

  spec.summary       = 'A Ruby implementation of the Monkey language.'
  spec.description   = 'A Ruby inspired implementation of the Monkey language.'
  spec.homepage      = 'https://github.com/fzakaria/monkeylang'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/fzakaria/monkeylang'
  spec.metadata['changelog_uri'] = 'https://github.com/fzakaria/monkeylang/blob/master/CHANGELOG'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'sorbet-runtime'

  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sorbet'
end
