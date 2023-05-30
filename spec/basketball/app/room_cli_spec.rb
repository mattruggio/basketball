# frozen_string_literal: true

require 'spec_helper'

describe Basketball::App::RoomCLI do
  describe 'feature tests' do
    let(:input_path) { fixture_path(dir, 'input.json') }
    let(:io)         { StringIO.new }
    let(:prefix)     { "#{SecureRandom.uuid}-" }

    context 'with no fuzz' do
      let(:dir) { File.join('draft', 'no_fuzz_draft') }

      specify 'no sim picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{prefix}0-0.json")
        args          = ['-i', input_path, '-o', output_path]
        expected_path = fixture_path(dir, 'output', '0-0.json')

        described_class.new(args:, io:).invoke!

        expect(output_path).to produce_same_json_draft(expected_path)
      end

      specify 'sim 1 pick' do
        output_path   = File.join(TEMP_DIR, dir, "#{prefix}1-1.json")
        args          = ['-i', input_path, '-o', output_path, '-s', '1']
        expected_path = fixture_path(dir, 'output', '1-1.json')

        described_class.new(args:, io:).invoke!

        expect(output_path).to produce_same_json_draft(expected_path)
      end

      specify 'sim all picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{prefix}3-3.json")
        args          = ['-i', input_path, '-o', output_path, '-a']
        expected_path = fixture_path(dir, 'output', '3-3.json')

        described_class.new(args:, io:).invoke!

        expect(output_path).to produce_same_json_draft(expected_path)
      end
    end

    context 'with no sim picks' do
      let(:dir) { File.join('draft', 'no_sim_draft') }

      specify 'sim all picks' do
        output_path   = File.join(TEMP_DIR, dir, "#{prefix}3-3.json")
        expected_path = fixture_path(dir, 'output', '3-3.json')
        picks         = %w[P-5 P-6 P-7 P-1 P-3 P-2 P-11 P-13 P-15].join(',')
        args          = ['-i', input_path, '-o', output_path, '-p', picks]

        described_class.new(args:, io:).invoke!

        expect(output_path).to produce_same_json_draft(expected_path)
      end
    end
  end
end
