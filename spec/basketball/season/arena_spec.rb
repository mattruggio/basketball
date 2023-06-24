# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::Arena do
  subject(:arena) do
    described_class.new(strategy_frquencies:, max_home_advantage:)
  end

  let(:max_home_advantage) { 0 }

  let(:game) do
    make_regular(
      date: Date.new(2022, 11, 3),
      home_opponent: bunnies_opp,
      away_opponent: rabbits_opp
    )
  end

  let(:bunnies_opp) { Basketball::Season::Opponent.new(id: 'bunnies_opp') }
  let(:rabbits_opp) { Basketball::Season::Opponent.new(id: 'rabbits_opp') }

  let(:bunnies_players) do
    [
      Basketball::Season::Player.new(id: 'P1', overall: 90, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P2', overall: 80, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P3', overall: 70, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P4', overall: 60, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P5', overall: 50, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P6', overall: 40, position: Basketball::Season::Position.new('C'))

    ]
  end

  let(:rabbits_players) do
    [
      Basketball::Season::Player.new(id: 'P7', overall: 89, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P8', overall: 88, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P9', overall: 87, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P10', overall: 86, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P11', overall: 85, position: Basketball::Season::Position.new('C')),
      Basketball::Season::Player.new(id: 'P12', overall: 84, position: Basketball::Season::Position.new('C'))
    ]
  end

  let(:matchup) do
    Basketball::Season::Matchup.new(
      game:,
      home_players: bunnies_players,
      away_players: rabbits_players
    )
  end

  context 'with top one strategy' do
    let(:strategy_frquencies) { { Basketball::Season::Arena::TOP_ONE => 1 } }

    specify 'team with best overall player wins' do
      result = arena.play(matchup)

      expect(result.home_score > result.away_score).to be true
    end
  end

  context 'with top two strategy' do
    let(:strategy_frquencies) { { Basketball::Season::Arena::TOP_TWO => 1 } }

    specify 'team with best two overall players wins' do
      result = arena.play(matchup)

      expect(result.home_score < result.away_score).to be true
    end
  end

  context 'with top three strategy' do
    let(:strategy_frquencies) { { Basketball::Season::Arena::TOP_THREE => 1 } }

    specify 'team with best three overall players wins' do
      result = arena.play(matchup)

      expect(result.home_score < result.away_score).to be true
    end
  end

  context 'with top six strategy' do
    let(:strategy_frquencies) { { Basketball::Season::Arena::TOP_SIX => 1 } }

    specify 'team with best six overall players wins' do
      result = arena.play(matchup)

      expect(result.home_score < result.away_score).to be true
    end
  end
end
