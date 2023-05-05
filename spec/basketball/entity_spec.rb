# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Entity do
  subject(:entity) do
    described_class.new(id)
  end

  let(:id) { 'p1234' }

  describe 'initialization' do
    it 'requires id' do
      expect { described_class.new('') }.to raise_error(ArgumentError)
    end

    it 'sets id as uppercased string' do
      expect(entity.id).to eq(id.to_s.upcase)
    end
  end

  describe 'equality' do
    specify '==' do
      expect(entity == described_class.new(id)).to be true
    end

    specify 'eq?' do
      expect(entity).to eq(described_class.new(id))
    end

    specify 'eql?' do
      expect(entity).to eql(described_class.new(id))
    end
  end

  describe 'sorting' do
    it 'lexically compares ids' do
      actual = [
        described_class.new('zyx'),
        described_class.new('mno'),
        described_class.new('a0'),
        described_class.new('abc')
      ].sort

      expected = [
        described_class.new('a0'),
        described_class.new('abc'),
        described_class.new('mno'),
        described_class.new('zyx')
      ].sort

      expect(actual).to eq(expected)
    end
  end

  describe '#to_s' do
    it 'includes the id' do
      expect(entity.to_s).to include(id.upcase)
    end
  end
end
