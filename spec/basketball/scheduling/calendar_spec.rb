# frozen_string_literal: true

require 'spec_helper'
require 'scheduling_helper'

describe Basketball::Scheduling::Calendar do
  subject(:calendar) { described_class.new(games:) }

  let(:bunnies) { make_team(id: 'bunnies', name: 'the bunnies') }
  let(:rabbits) { make_team(id: 'rabbits', name: 'the rabbits') }
  let(:santas)  { make_team(id: 'santas', name: 'the santas') }
  let(:rizzos)  { make_team(id: 'rizzos', name: 'the rizzos') }

  let(:games) do
    [
      make_preseason_game(date: '2023-01-02', home_team: bunnies, away_team: rabbits),
      make_preseason_game(date: '2023-01-03', home_team: rabbits, away_team: bunnies),
      make_season_game(date: '2023-01-04', home_team: bunnies, away_team: rabbits),
      make_season_game(date: '2023-01-05', home_team: rabbits, away_team: bunnies)
    ]
  end

  describe 'initialization' do
    it 'sets games' do
      expect(calendar.games).to eq(games)
    end
  end

  describe '#add!' do
    it 'adds new game' do
      new_game = make_season_game(date: '2023-01-06', home_team: bunnies, away_team: rabbits)

      calendar.add!(new_game)

      expect(calendar.games).to include(new_game)
    end

    it 'prevents home team from playing on same day' do
      new_game = make_season_game(date: '2023-01-02', home_team: bunnies, away_team: santas)
      error    = described_class::TeamAlreadyBookedError

      expect { calendar.add!(new_game) }.to raise_error(error)
    end

    it 'prevents away team from playing on same day' do
      new_game = make_season_game(date: '2023-01-02', home_team: santas, away_team: bunnies)
      error    = described_class::TeamAlreadyBookedError

      expect { calendar.add!(new_game) }.to raise_error(error)
    end

    it 'prevents scheduling preseason on first regular season date' do
      new_game = make_preseason_game(date: '2023-01-04', home_team: santas, away_team: rizzos)
      error    = described_class::InvalidGameOrderError

      expect { calendar.add!(new_game) }.to raise_error(error)
    end

    it 'prevents scheduling preseason after first regular season date' do
      new_game = make_preseason_game(date: '2023-02-04', home_team: santas, away_team: rizzos)
      error    = described_class::InvalidGameOrderError

      expect { calendar.add!(new_game) }.to raise_error(error)
    end

    it 'prevents scheduling season on last preseason date' do
      new_game = make_season_game(date: '2023-01-03', home_team: santas, away_team: rizzos)
      error    = described_class::InvalidGameOrderError

      expect { calendar.add!(new_game) }.to raise_error(error)
    end

    it 'prevents scheduling season before last preseason date' do
      new_game = make_season_game(date: '2022-12-29', home_team: santas, away_team: rizzos)
      error    = described_class::InvalidGameOrderError

      expect { calendar.add!(new_game) }.to raise_error(error)
    end
  end
end
