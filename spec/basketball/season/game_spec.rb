# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Season::Game do
  subject(:game) { described_class.new(date:, home_opponent:, away_opponent:) }

  let(:date) { Date.parse('2023-01-02') }
  let(:home_opponent) { Basketball::Season::Team.new(id: 'ht') }
  let(:away_opponent) { Basketball::Season::Team.new(id: 'at') }

  describe '#initialize' do
    it 'sets date' do
      expect(game.date).to eq(date)
    end

    it 'sets home_opponent' do
      expect(game.home_opponent).to eq(home_opponent)
    end

    it 'sets away_opponent' do
      expect(game.away_opponent).to eq(away_opponent)
    end

    it 'prevents team from playing itself' do
      expect do
        described_class.new(
          date:,
          home_opponent:,
          away_opponent: home_opponent
        )
      end.to raise_error(ArgumentError)
    end
  end

  describe '#teams' do
    it 'includes home team' do
      expect(game.teams).to include(home_opponent)
    end

    it 'includes away team' do
      expect(game.teams).to include(away_opponent)
    end
  end

  describe '#to_s' do
    it 'includes date' do
      expect(game.to_s).to include(date.to_s)
    end

    it 'includes home team' do
      expect(game.to_s).to include(home_opponent.to_s)
    end

    it 'includes away team' do
      expect(game.to_s).to include(away_opponent.to_s)
    end
  end
end
