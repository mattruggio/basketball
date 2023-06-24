# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Season::Result do
  subject(:result) { described_class.new(game:, home_score:, away_score:) }

  let(:game)          { Basketball::Season::Game.new(date:, home_opponent:, away_opponent:) }
  let(:date)          { Date.new(2023, 1, 2) }
  let(:home_opponent) { Basketball::Season::Team.new(id: 'ht') }
  let(:away_opponent) { Basketball::Season::Team.new(id: 'at') }
  let(:home_score)    { 2 }
  let(:away_score)    { 1 }

  describe '#initialize' do
    it 'sets game' do
      expect(result.game).to eq(game)
    end

    it 'sets home score' do
      expect(result.home_score).to eq(home_score)
    end

    it 'sets away score' do
      expect(result.away_score).to eq(away_score)
    end
  end

  describe '#to_s' do
    it 'includes date' do
      expect(result.to_s).to include(date.to_s)
    end

    it 'includes home team' do
      expect(result.to_s).to include(home_opponent.to_s)
    end

    it 'includes away team' do
      expect(result.to_s).to include(away_opponent.to_s)
    end

    it 'includes home score' do
      expect(result.to_s).to include(home_score.to_s)
    end

    it 'includes away score' do
      expect(result.to_s).to include(away_score.to_s)
    end
  end
end
