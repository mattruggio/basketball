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

def json_parse(json)
  JSON.parse(json, symbolize_names: true)
end

def fixture_path(*)
  File.join('spec', 'fixtures', *)
end

def read_fixture(*)
  File.read(fixture_path(*))
end

def read_json_fixture(*)
  JSON.parse(read_fixture(*), symbolize_names: true)
end

def read_json_temp_file(*)
  JSON.parse(read_temp_file(*), symbolize_names: true)
end

def read_temp_file(*)
  File.read(temp_path(*))
end

def temp_path(*)
  File.join(TEMP_DIR, *)
end

def write_file(path, contents)
  dir = File.dirname(path)

  FileUtils.mkdir_p(dir)

  File.write(path, contents)
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
