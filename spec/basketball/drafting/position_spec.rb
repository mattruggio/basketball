# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Drafting::Position do
  subject(:position) do
    described_class.new(value)
  end

  let(:value) { 'c' }

  describe 'initialization' do
    it 'sets value' do
      expect(position.value).to eq(value.upcase)
    end

    it 'accepts symbols for value' do
      expect(described_class.new(:pf).value).to eq('PF')
    end

    it 'raises InvalidPositionError for unknown values' do
      expect { described_class.new(:bench) }.to raise_error(described_class::InvalidPositionError)
    end
  end

  describe '#to_s' do
    it 'includes value' do
      expect(position.to_s).to include(value.upcase)
    end
  end
end
