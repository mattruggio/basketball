# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::Calendar do
  subject(:calendar) do
    described_class.new(
      exhibition_start_date:,
      exhibition_end_date:,
      regular_start_date:,
      regular_end_date:,
      games:
    )
  end

  let(:exhibition_start_date) { Date.new(2022, 10, 1) }
  let(:exhibition_end_date)   { Date.new(2022, 10, 14) }
  let(:regular_start_date)    { Date.new(2022, 10, 16) }
  let(:regular_end_date)      { Date.new(2023, 4, 29) }

  let(:bunnies_opp)   { Basketball::Season::Opponent.new(id: 'bunnies_opp') }
  let(:rabbits_opp)   { Basketball::Season::Opponent.new(id: 'rabbits_opp') }
  let(:santas_opp)    { Basketball::Season::Opponent.new(id: 'santas_opp') }
  let(:rizzos_opp)    { Basketball::Season::Opponent.new(id: 'rizzos_opp') }
  let(:opponent_type) { Basketball::Season::OpponentType::INTRA_DIVISIONAL }

  let(:exhibitions) do
    [
      make_exhibition(date: Date.new(2022, 10, 1), home_opponent: bunnies_opp, away_opponent: rabbits_opp,
                      opponent_type:),
      make_exhibition(date: Date.new(2022, 10, 2), home_opponent: rabbits_opp, away_opponent: bunnies_opp,
                      opponent_type:)
    ]
  end

  let(:regulars) do
    [
      make_regular(date: Date.new(2022, 11, 3), home_opponent: bunnies_opp, away_opponent: rabbits_opp, opponent_type:),
      make_regular(date: Date.new(2023, 1, 4), home_opponent: rabbits_opp, away_opponent: bunnies_opp, opponent_type:)
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

  describe '#available_exhibition_dates_for' do
    it 'returns dates team is not scheduled' do
      actual_dates   = calendar.available_exhibition_dates_for(bunnies_opp)
      expected_dates = (Date.new(2022, 10, 1)..Date.new(2022, 10, 14)).to_a - exhibitions.map(&:date)

      expect(actual_dates).to eq(expected_dates)
    end
  end

  describe '#available_regular_dates_for' do
    it 'returns dates team is not scheduled' do
      actual_dates   = calendar.available_regular_dates_for(bunnies_opp)
      expected_dates = (Date.new(2022, 10, 16)..Date.new(2023, 4, 29)).to_a - regulars.map(&:date)

      expect(actual_dates).to eq(expected_dates)
    end
  end

  describe '#add!' do
    context 'when adding a regular game' do
      it 'adds new game' do
        new_game = make_regular(
          date: Date.new(2023, 3, 4),
          home_opponent: bunnies_opp,
          away_opponent: rabbits_opp,
          opponent_type:
        )

        calendar.add!(new_game)

        expect(calendar.games).to include(new_game)
      end

      it 'prevents home team from playing on same day' do
        new_game = make_regular(
          date: Date.new(2022, 11, 3),
          home_opponent: bunnies_opp,
          away_opponent: santas_opp,
          opponent_type:
        )

        error = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents away team from playing on same day' do
        new_game = make_regular(
          date: Date.new(2022, 11, 3),
          home_opponent: santas_opp,
          away_opponent: bunnies_opp,
          opponent_type:
        )

        error = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents regular during exhibition' do
        new_game = make_regular(
          date: Date.new(2022, 10, 3),
          home_opponent: santas_opp,
          away_opponent: rizzos_opp,
          opponent_type:
        )

        error = described_class::OutOfBoundsError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents unknown game class constants' do
        new_game = PlayoffGame.new(
          date: Date.new(2022, 10, 3),
          home_opponent: santas_opp,
          away_opponent: rizzos_opp,
          opponent_type:
        )

        expect { calendar.add!(new_game) }.to raise_error(ArgumentError)
      end
    end

    context 'when adding an exhibition game' do
      it 'adds new game' do
        new_game = make_exhibition(
          date: Date.new(2022, 10, 3),
          home_opponent: bunnies_opp,
          away_opponent: rabbits_opp,
          opponent_type:
        )

        calendar.add!(new_game)

        expect(calendar.games).to include(new_game)
      end

      it 'prevents home team from playing on same day' do
        new_game = make_exhibition(
          date: Date.new(2022, 10, 2),
          home_opponent: bunnies_opp,
          away_opponent: santas_opp,
          opponent_type:
        )

        error = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents away team from playing on same day' do
        new_game = make_exhibition(
          date: Date.new(2022, 10, 2),
          home_opponent: santas_opp,
          away_opponent: bunnies_opp,
          opponent_type:
        )

        error = described_class::TeamAlreadyBookedError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end

      it 'prevents exhibition during regular season' do
        new_game = make_exhibition(
          date: calendar.regular_start_date + 10,
          home_opponent: santas_opp,
          away_opponent: rizzos_opp,
          opponent_type:
        )

        error = described_class::OutOfBoundsError

        expect { calendar.add!(new_game) }.to raise_error(error)
      end
    end
  end
end
