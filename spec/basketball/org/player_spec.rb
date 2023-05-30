# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Org::Player do
  let(:player) { described_class.new(id:, overall:) }

  let(:id)      { 'p1234' }
  let(:overall) { 95 }

  describe '#initialize' do
    it 'sets id' do
      expect(player.id).to eq(id)
    end

    it 'sets overall' do
      expect(player.overall).to eq(overall)
    end
  end

  describe '#to_s' do
    it 'contains overall' do
      expect(player.to_s).to include(overall.to_s)
    end
  end
end
