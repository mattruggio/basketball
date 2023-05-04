# frozen_string_literal: true

require 'pry'

unless ENV['DISABLE_SIMPLECOV'] == 'true'
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.formatter = SimpleCov::Formatter::Console
  SimpleCov.start do
    add_filter %r{\A/spec/}
  end
end

def fixture_path(*path)
  File.join('spec', 'fixtures', *path)
end

def read_yaml_fixture(*path)
  YAML.safe_load(read_fixture(*path))
end

def read_fixture(*path)
  File.read(fixture_path(*path))
end

TEMP_DIR = File.join('tmp', 'spec')

RSpec.configure do |config|
  config.before(:suite) do
    FileUtils.rm_rf(TEMP_DIR)
  end
end

require 'rspec/expectations'
require './lib/basketball'
