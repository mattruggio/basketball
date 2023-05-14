# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::Position do
  subject(:position) { described_class.new(code) }

  let(:code) { 'c' }

  describe 'initialization' do
    it 'sets code' do
      expect(position.code).to eq(code.upcase)
    end

    it 'accepts symbols for code' do
      expect(described_class.new(:pf).code).to eq('PF')
    end

    it 'raises InvalidPositionError for unknown codes' do
      expect { described_class.new(:bench) }.to raise_error(described_class::InvalidPositionError)
    end
  end

  describe 'equality' do
    specify '==' do
      expect(position == described_class.new(code)).to be true
    end

    specify 'eq?' do
      expect(position).to eq(described_class.new(code))
    end

    specify 'eql?' do
      expect(position).to eql(described_class.new(code))
    end
  end

  describe '#to_s' do
    it 'includes code' do
      expect(position.to_s).to include(code.upcase)
    end
  end
end
