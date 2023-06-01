# frozen_string_literal: true

require 'spec_helper'

class Money < Basketball::ValueObject
  value_reader :currency, :value

  def initialize(currency, value)
    super()

    @currency = currency
    @value    = value
  end
end

describe Basketball::ValueObject do
  subject(:money) { Money.new(currency, value) }

  let(:value)    { 123.45 }
  let(:currency) { 'USD' }

  describe '#to_s' do
    it 'contains value' do
      expect(money.to_s).to include(value.to_s)
    end

    it 'contains currency' do
      expect(money.to_s).to include(currency.to_s)
    end
  end

  describe '#[]' do
    it 'accesses currency' do
      expect(money[:currency]).to eq(currency)
    end
  end

  describe 'sorting' do
    it 'compares by alphabetical keys values' do
      actual = [
        Money.new('USD', 456),
        Money.new('USD', 123),
        Money.new('GBP', 999),
        Money.new('GBP', 555)
      ].sort

      expected = [
        Money.new('GBP', 555),
        Money.new('GBP', 999),
        Money.new('USD', 123),
        Money.new('USD', 456)
      ]

      expect(actual).to eq(expected)
    end
  end

  describe 'equality' do
    let(:same_money) { Money.new(currency, value) }

    specify '#==' do
      expect(money == same_money).to be true
    end

    specify '#eq?' do
      expect(money).to eq(same_money)
    end

    specify '#eql?' do
      expect(money).to eql(same_money)
    end
  end

  describe '#hash' do
    it 'equals hash of the alphabetical keys values hashes' do
      expected = [currency, value].hash

      expect(money.hash).to eq(expected)
    end
  end
end
