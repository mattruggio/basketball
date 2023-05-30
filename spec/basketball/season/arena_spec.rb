# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Season::Arena do
  subject(:arena) { described_class.new }

  let(:matchup)       { Basketball::Season::Matchup.new(game:, home_players:, away_players:) }
  let(:game)          { Basketball::Season::Game.new(date:, home_opponent:, away_opponent:) }
  let(:date)          { Date.parse('2023-01-02') }
  let(:home_opponent) { Basketball::Season::Opponent.new(id: 'ht') }
  let(:away_opponent) { Basketball::Season::Opponent.new(id: 'at') }
  let(:home_players)  { [] }
  let(:away_players)  { [] }

  describe '#play' do
    context 'when home team has same overalls as away team' do
      let(:home_players) do
        [
          Basketball::Org::Player.new(id: 'p1', overall: 90, position: Basketball::Org::Position.new('C')),
          Basketball::Org::Player.new(id: 'p2', overall: 80, position: Basketball::Org::Position.new('C'))
        ]
      end

      let(:away_players) do
        [
          Basketball::Org::Player.new(id: 'p3', overall: 90, position: Basketball::Org::Position.new('C')),
          Basketball::Org::Player.new(id: 'p4', overall: 80, position: Basketball::Org::Position.new('C'))
        ]
      end

      it 'home team wins or tie' do
        actual = arena.play(matchup)

        expect(actual.home_score >= actual.away_score).to be true
      end
    end

    context 'when away team has better overalls as home team' do
      let(:home_players) do
        [
          Basketball::Org::Player.new(id: 'p1', overall: 70, position: Basketball::Org::Position.new('C')),
          Basketball::Org::Player.new(id: 'p2', overall: 60, position: Basketball::Org::Position.new('C'))
        ]
      end

      let(:away_players) do
        [
          Basketball::Org::Player.new(id: 'p3', overall: 90, position: Basketball::Org::Position.new('C')),
          Basketball::Org::Player.new(id: 'p4', overall: 80, position: Basketball::Org::Position.new('C'))
        ]
      end

      it 'away team wins or tie' do
        actual = arena.play(matchup)

        expect(actual.away_score >= actual.home_score).to be true
      end
    end

    describe 'returns' do
      it 'game result event' do
        expect(arena.play(matchup)).to be_a(Basketball::Season::Result)
      end

      it 'game' do
        actual = arena.play(matchup)

        expect(actual.game).to eq(game)
      end
    end
  end
end
