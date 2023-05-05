# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/NoExpectationExample
describe Basketball::Drafting::CLI do
  describe 'feature tests' do
    let(:input_path) { fixture_path(dir, 'input.json') }
    let(:io)         { StringIO.new }

    context 'with no fuzz and no depth' do
      let(:dir) { 'no_fuzz_no_depth_draft' }

      specify 'no sim picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-0-0.json")
        args          = ['-i', input_path, '-o', output_path]
        expected_path = fixture_path(dir, 'output', '0-0.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end

      specify 'sim 1 pick' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-1-1.json")
        args          = ['-i', input_path, '-o', output_path, '-s', '1']
        expected_path = fixture_path(dir, 'output', '1-1.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end

      specify 'sim 2 picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-1-2.json")
        args          = ['-i', input_path, '-o', output_path, '-s', '2']
        expected_path = fixture_path(dir, 'output', '1-2.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end

      specify 'sim 3 picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-1-3.json")
        args          = ['-i', input_path, '-o', output_path, '-s', '3']
        expected_path = fixture_path(dir, 'output', '1-3.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end

      specify 'sim 4 picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-2-1.json")
        args          = ['-i', input_path, '-o', output_path, '-s', '3']
        expected_path = fixture_path(dir, 'output', '2-1.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end

      specify 'sim all picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-3-3.json")
        args          = ['-i', input_path, '-o', output_path, '-a']
        expected_path = fixture_path(dir, 'output', '3-3.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end
    end

    context 'with no fuzz' do
      let(:dir) { 'no_fuzz_draft' }

      specify 'no sim picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-0-0.json")
        args          = ['-i', input_path, '-o', output_path]
        expected_path = fixture_path(dir, 'output', '0-0.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end

      specify 'sim 1 pick' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-1-1.json")
        args          = ['-i', input_path, '-o', output_path, '-s', '1']
        expected_path = fixture_path(dir, 'output', '1-1.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end

      specify 'sim all picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-3-3.json")
        args          = ['-i', input_path, '-o', output_path, '-a']
        expected_path = fixture_path(dir, 'output', '3-3.json')

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end
    end

    context 'with no sim picks' do
      let(:dir) { 'no_sim_draft' }

      specify 'sim all picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{SecureRandom.uuid}-3-3.json")
        expected_path = fixture_path(dir, 'output', '3-3.json')
        picks         = %w[P-5 P-6 P-7 P-1 P-3 P-2 P-11 P-13 P-15].join(',')
        args          = ['-i', input_path, '-o', output_path, '-p', picks]

        described_class.new(args:, io:).invoke!

        compare_outputs(output_path, expected_path)
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def compare_outputs(actual_path, expected_path)
    actual   = JSON.parse(File.read(actual_path), symbolize_names: true)
    expected = JSON.parse(File.read(expected_path), symbolize_names: true)

    (actual.dig(:engine, :events) || []).each { |event| event[:id] = nil }
    (expected.dig(:engine, :events) || []).each { |event| event[:id] = nil }

    expect(actual[:info]).to                 eq(expected[:info])
    expect(actual.dig(:engine, :teams)).to   eq(expected.dig(:engine, :teams))
    expect(actual.dig(:engine, :players)).to eq(expected.dig(:engine, :players))
    expect(actual.dig(:engine, :events)).to  eq(expected.dig(:engine, :events))
    expect(actual[:rosters]).to              eq(expected[:rosters])
  end
  # rubocop:enable Metrics/AbcSize
end
# rubocop:enable RSpec/NoExpectationExample
