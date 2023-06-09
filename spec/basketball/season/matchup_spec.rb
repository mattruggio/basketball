# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Season::Matchup do
  subject(:matchup) { described_class.new(game:, home_players:, away_players:) }

  let(:game)          { Basketball::Season::Game.new(date:, home_opponent:, away_opponent:, opponent_type:) }
  let(:date)          { Date.parse('2023-01-02') }
  let(:home_opponent) { Basketball::Season::Team.new(id: 'ht') }
  let(:away_opponent) { Basketball::Season::Team.new(id: 'at') }
  let(:home_players)  { [] }
  let(:away_players)  { [] }
  let(:opponent_type) { Basketball::Season::OpponentType::INTRA_DIVISIONAL }

  describe '#initialize' do
    it 'sets game' do
      expect(matchup.game).to eq(game)
    end

    it 'prevents players being on both teams' do
      players = [
        Basketball::Season::Player.new(id: 'p1', overall: 99, position: Basketball::Season::Position.new('C'))
      ]

      expect do
        described_class.new(
          game:,
          home_players: players,
          away_players: players
        )
      end.to raise_error(described_class::PlayersOnBothTeamsError)
    end
  end
end
