# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::Calendar do
  subject(:calendar) do
    described_class.new(year:, games:)
  end

  let(:year)    { 2022 }
  let(:bunnies) { make_team(id: 'bunnies', name: 'the bunnies') }
  let(:rabbits) { make_team(id: 'rabbits', name: 'the rabbits') }
  let(:santas)  { make_team(id: 'santas', name: 'the santas') }
  let(:rizzos)  { make_team(id: 'rizzos', name: 'the rizzos') }

  let(:preseason_games) do
    [
      make_preseason_game(date: Date.parse('2022-10-01'), home_team: bunnies, away_team: rabbits),
      make_preseason_game(date: Date.parse('2022-10-02'), home_team: rabbits, away_team: bunnies)
    ]
  end

  let(:season_games) do
    [
      make_season_game(date: Date.parse('2022-11-03'), home_team: bunnies, away_team: rabbits),
      make_season_game(date: Date.parse('2023-01-04'), home_team: rabbits, away_team: bunnies)
    ]
  end

  let(:games) { preseason_games + season_games }

  describe 'initialization' do
    it 'sets games' do
      expect(calendar.games).to eq(games)
    end
  end

  describe '#preseason_games_for' do
    it 'returns all' do
      actual_games = calendar.preseason_games_for

      expect(actual_games).to eq(preseason_games)
    end
  end

  describe '#season_games_for' do
    it 'returns all' do
      actual_games = calendar.season_games_for

      expect(actual_games).to eq(season_games)
    end
  end

  describe '#games_for' do
    it 'returns all' do
      actual_games = calendar.games_for

      expect(actual_games).to eq(games)
    end
  end

  describe '#available_preseason_dates_for' do
    it 'returns dates team is not scheduled' do
      actual_dates   = calendar.available_preseason_dates_for(bunnies)
      expected_dates = (Date.new(2022, 9, 30)..Date.new(2022, 10, 14)).to_a - preseason_games.map(&:date)

      expect(actual_dates).to eq(expected_dates)
    end
  end

  describe '#available_season_dates_for' do
    it 'returns dates team is not scheduled' do
      actual_dates   = calendar.available_season_dates_for(bunnies)
      expected_dates = (Date.new(2022, 10, 18)..Date.new(2023, 4, 29)).to_a - season_games.map(&:date)

      expect(actual_dates).to eq(expected_dates)
    end
  end

  describe '#add!' do
    context 'when adding a season game' do
      it 'adds new game' do
        new_game = make_season_game(date: Date.parse('2023-03-04'), home_team: bunnies, away_team: rabbits)

        calendar.add!(new_game)

        expect(calendar.games).to include(new_game)
      end

      it 'prevents home team from playing on same day' do
        new_game = make_season_game(date: Date.parse('2022-11-03'), home_team: bunnies, away_team: santas)
        error    = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents away team from playing on same day' do
        new_game = make_season_game(date: Date.parse('2022-11-03'), home_team: santas, away_team: bunnies)
        error    = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents season during preseason' do
        new_game = make_season_game(date: Date.parse('2022-10-03'), home_team: santas, away_team: rizzos)
        error    = described_class::OutOfBoundsError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end
    end

    context 'when adding a preseason game' do
      it 'adds new game' do
        new_game = make_preseason_game(date: Date.parse('2022-10-03'), home_team: bunnies, away_team: rabbits)

        calendar.add!(new_game)

        expect(calendar.games).to include(new_game)
      end

      it 'prevents home team from playing on same day' do
        new_game = make_preseason_game(date: Date.parse('2022-10-02'), home_team: bunnies, away_team: santas)
        error    = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents away team from playing on same day' do
        new_game = make_preseason_game(date: Date.parse('2022-10-02'), home_team: santas, away_team: bunnies)
        error    = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents season preseason during regular season' do
        new_game = make_preseason_game(date: calendar.season_start_date + 10, home_team: santas, away_team: rizzos)
        error    = described_class::OutOfBoundsError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end
    end
  end
end
