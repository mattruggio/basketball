# frozen_string_literal: true

require './lib/basketball/version'

Gem::Specification.new do |s|
  s.name        = 'basketball'
  s.version     = Basketball::VERSION
  s.summary     = 'Basketball League Game Engine'

  s.description = <<-DESC
    This library is meant to serve as the domain for a basketball league/season simulator/turn-based game.
    It models core ideas such as: players, general managers, draft strategy, drafting, season generation, season simultation,
    playoff generation, playoff simulation, and more.
  DESC

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mattruggio@icloud.com']
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(.github|bin|docs|spec)/}) }
  s.bindir      = 'exe'
  s.executables = %w[basketball-draft]
  s.homepage    = 'https://github.com/mattruggio/basketball'
  s.license     = 'MIT'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/mattruggio/basketball/issues',
    'changelog_uri' => 'https://github.com/mattruggio/basketball/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/basketball',
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage,
    'rubygems_mfa_required' => 'true'
  }

  s.required_ruby_version = '>= 3.2.1'

  s.add_dependency('faker', '~>3.2')
  s.add_dependency('slop', '~>4.10')

  s.add_development_dependency('bundler-audit', '~>0.9')
  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pry', '~>0.14')
  s.add_development_dependency('rake', '~>13.0')
  s.add_development_dependency('rspec', '~>3.12')
  s.add_development_dependency('rubocop', '~>1.49')
  s.add_development_dependency('rubocop-rake', '~>0.6')
  s.add_development_dependency('rubocop-rspec', '~>2.20')
  s.add_development_dependency('simplecov', '~>0.22')
  s.add_development_dependency('simplecov-console', '~>0.9')
end
