# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Entity do
  subject(:entity) { described_class.new(id) }

  let(:id) { 'p1234' }

  describe '#initialize' do
    it 'sets id as string' do
      expect(entity.id).to eq(id.to_s)
    end
  end

  describe 'equality' do
    specify '#==' do
      expect(entity == described_class.new(id)).to be true
    end

    specify '#== is case-insensitive' do
      expect(entity == described_class.new(id.upcase)).to be true
    end

    specify '#eq?' do
      expect(entity).to eq(described_class.new(id))
    end

    specify '#eq? is case-insensitive' do
      expect(entity).to eq(described_class.new(id.upcase))
    end

    specify '#eql?' do
      expect(entity).to eql(described_class.new(id))
    end

    specify '#eql? is case-insensitive' do
      expect(entity).to eql(described_class.new(id.upcase))
    end

    specify '#hash is based on upper-cased ID string value' do
      expect(entity.hash).to eq(id.upcase.hash)
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
      ]

      expect(actual).to eq(expected)
    end
  end

  describe '#to_s' do
    it 'includes the id' do
      expect(entity.to_s).to include(id)
    end
  end
end
