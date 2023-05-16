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

def read_fixture(*path)
  File.read(fixture_path(*path))
end

TEMP_DIR = File.join('tmp', 'spec')

RSpec.configure do |config|
  config.before(:suite) do
    FileUtils.rm_rf(TEMP_DIR)
  end

  RSpec::Matchers.define :produce_same_json_draft do |expected_path|
    match do |actual_path|
      actual   = JSON.parse(File.read(actual_path), symbolize_names: true)
      expected = JSON.parse(File.read(expected_path), symbolize_names: true)

      actual[:info] == expected[:info] &&
        actual.dig(:room, :front_offices) == expected.dig(:room, :front_offices) &&
        actual.dig(:room, :players) == expected.dig(:room, :players) &&
        actual.dig(:room, :events) == expected.dig(:room, :events) &&
        actual[:league] == expected[:league]
    end

    failure_message do |actual_path|
      "expected that #{actual_path} would have equal parts to #{expected_path}"
    end
  end
end

require 'rspec/expectations'
require './lib/basketball'
