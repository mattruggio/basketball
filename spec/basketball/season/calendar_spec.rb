# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::Calendar do
  subject(:calendar) do
    described_class.new(
      preseason_start_date:,
      preseason_end_date:,
      season_start_date:,
      season_end_date:,
      games:
    )
  end

  let(:preseason_start_date) { Date.new(2022, 10, 1) }
  let(:preseason_end_date)   { Date.new(2022, 10, 14) }
  let(:season_start_date)    { Date.new(2022, 10, 16) }
  let(:season_end_date)      { Date.new(2023, 4, 29) }

  let(:bunnies_opp) { Basketball::Season::Opponent.new(id: 'bunnies_opp') }
  let(:rabbits_opp) { Basketball::Season::Opponent.new(id: 'rabbits_opp') }
  let(:santas_opp)  { Basketball::Season::Opponent.new(id: 'santas_opp') }
  let(:rizzos_opp)  { Basketball::Season::Opponent.new(id: 'rizzos_opp') }

  let(:exhibitions) do
    [
      make_exhibition(date: Date.new(2022, 10, 1), home_opponent: bunnies_opp, away_opponent: rabbits_opp),
      make_exhibition(date: Date.new(2022, 10, 2), home_opponent: rabbits_opp, away_opponent: bunnies_opp)
    ]
  end

  let(:regulars) do
    [
      make_regular(date: Date.new(2022, 11, 3), home_opponent: bunnies_opp, away_opponent: rabbits_opp),
      make_regular(date: Date.new(2023, 1, 4), home_opponent: rabbits_opp, away_opponent: bunnies_opp)
    ]
  end

  let(:games) { exhibitions + regulars }

  describe 'initialization' do
    it 'sets games' do
      expect(calendar.games).to eq(games)
    end
  end

  describe '#exhibitions_for' do
    it 'returns all' do
      actual_games = calendar.exhibitions_for

      expect(actual_games).to eq(exhibitions)
    end
  end

  describe '#regulars_for' do
    it 'returns all' do
      actual_games = calendar.regulars_for

      expect(actual_games).to eq(regulars)
    end
  end

  describe '#games_for' do
    it 'returns all' do
      actual_games = calendar.games_for

      expect(actual_games).to eq(games)
    end
  end

  describe '#add!' do
    context 'when adding a season game' do
      it 'adds new game' do
        new_game = make_regular(date: Date.new(2023, 3, 4), home_opponent: bunnies_opp, away_opponent: rabbits_opp)

        calendar.add!(new_game)

        expect(calendar.games).to include(new_game)
      end

      it 'prevents home team from playing on same day' do
        new_game = make_regular(date: Date.new(2022, 11, 3), home_opponent: bunnies_opp, away_opponent: santas_opp)
        error    = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents away team from playing on same day' do
        new_game = make_regular(date: Date.new(2022, 11, 3), home_opponent: santas_opp, away_opponent: bunnies_opp)
        error    = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents season during preseason' do
        new_game = make_regular(date: Date.new(2022, 10, 3), home_opponent: santas_opp, away_opponent: rizzos_opp)
        error    = described_class::OutOfBoundsError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents unknown game class constants' do
        new_game = PlayoffGame.new(date: Date.new(2022, 10, 3), home_opponent: santas_opp, away_opponent: rizzos_opp)

        expect { calendar.add!(new_game) }.to raise_error(ArgumentError)
      end
    end

    context 'when adding a preseason game' do
      it 'adds new game' do
        new_game = make_exhibition(date: Date.new(2022, 10, 3), home_opponent: bunnies_opp, away_opponent: rabbits_opp)

        calendar.add!(new_game)

        expect(calendar.games).to include(new_game)
      end

      it 'prevents home team from playing on same day' do
        new_game = make_exhibition(date: Date.new(2022, 10, 2), home_opponent: bunnies_opp, away_opponent: santas_opp)
        error    = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents away team from playing on same day' do
        new_game = make_exhibition(date: Date.new(2022, 10, 2), home_opponent: santas_opp, away_opponent: bunnies_opp)
        error    = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents season preseason during regular season' do
        new_game = make_exhibition(date: calendar.season_start_date + 10, home_opponent: santas_opp,
                                   away_opponent: rizzos_opp)
        error    = described_class::OutOfBoundsError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end
    end
  end
end
