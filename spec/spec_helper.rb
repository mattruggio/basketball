# frozen_string_literal: true

require 'pry'
require 'securerandom'

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

def read_json_fixture(*path)
  JSON.parse(read_fixture(*path), symbolize_names: true)
end

def read_json_temp_file(*path)
  JSON.parse(read_temp_file(*path), symbolize_names: true)
end

def read_temp_file(*path)
  File.read(temp_path(*path))
end

def temp_path(*path)
  File.join(TEMP_DIR, *path)
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

      actual[:front_offices] == expected[:front_offices] &&
        actual[:players] == expected[:players] &&
        actual[:events] == expected[:events] &&
        actual[:league] == expected[:league]
    end

    failure_message do |actual_path|
      actual   = JSON.parse(File.read(actual_path), symbolize_names: true)
      expected = JSON.parse(File.read(expected_path), symbolize_names: true)

      <<~DOC
        Expected that #{actual_path} would have equal parts to #{expected_path}
        Expected:
        #{expected.to_json}
        Actual:
        #{actual.to_json}
      DOC
    end
  end
end

require 'rspec/expectations'
require './lib/basketball'
