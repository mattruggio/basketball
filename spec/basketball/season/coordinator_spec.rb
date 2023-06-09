# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::Coordinator do
  subject(:coordinator) do
    described_class.new(calendar:, current_date:, league:).tap do |coordinator|
      coordinator.send('arena=', PredictableArena.new)
    end
  end

  let(:calendar) do
    Basketball::Season::Calendar.new(
      exhibition_start_date:,
      exhibition_end_date:,
      regular_start_date:,
      regular_end_date:,
      games:
    )
  end

  let(:current_date)          { Date.new(2022, 10, 1) }
  let(:exhibition_start_date) { Date.new(2022, 10, 1) }
  let(:exhibition_end_date)   { Date.new(2022, 10, 14) }
  let(:regular_start_date)    { Date.new(2022, 10, 16) }
  let(:regular_end_date)      { Date.new(2023, 4, 29) }
  let(:teams)                 { [bunnies, rabbits, santas, rizzos] }
  let(:league)                { Basketball::Season::League.new(conferences: [eastern], free_agents: [campy]) }
  let(:eastern)               { Basketball::Season::Conference.new(id: 'Eastern', divisions: [midwest]) }
  let(:midwest)               { Basketball::Season::Division.new(id: 'Midwest', teams:) }
  let(:campy)                 { Basketball::Season::Player.new(id: 'Campy', position:) }
  let(:position)              { Basketball::Season::Position.new('C') }

  let(:unknown) do
    Basketball::Season::Team.new(
      id: 'unknown',
      players: [
        Basketball::Season::Player.new(id: 'P99', position:),
        Basketball::Season::Player.new(id: 'P98', position:)
      ]
    )
  end

  let(:bunnies) do
    Basketball::Season::Team.new(
      id: 'bunnies',
      players: [
        Basketball::Season::Player.new(id: 'P1', position:),
        Basketball::Season::Player.new(id: 'P2', position:)
      ]
    )
  end

  let(:rabbits) do
    Basketball::Season::Team.new(
      id: 'rabbits',
      players: [
        Basketball::Season::Player.new(id: 'P3', position:),
        Basketball::Season::Player.new(id: 'P4', position:)
      ]
    )
  end

  let(:santas) do
    Basketball::Season::Team.new(
      id: 'santas',
      players: [
        Basketball::Season::Player.new(id: 'P5', position:)
      ]
    )
  end

  let(:rizzos) do
    Basketball::Season::Team.new(
      id: 'rizzos',
      players: [
        Basketball::Season::Player.new(id: 'P6', position:)
      ]
    )
  end

  let(:bunnies_opp)   { Basketball::Season::Opponent.new(id: 'bunnies') }
  let(:rabbits_opp)   { Basketball::Season::Opponent.new(id: 'rabbits') }
  let(:santas_opp)    { Basketball::Season::Opponent.new(id: 'santas') }
  let(:rizzos_opp)    { Basketball::Season::Opponent.new(id: 'rizzos') }
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
      expect(coordinator.games).to eq(games)
    end

    it 'replays game result events' do
      events = [
        Basketball::Season::Result.new(
          game: games.first,
          home_score: 153,
          away_score: 151
        )
      ]

      coordinator = described_class.new(
        calendar:,
        current_date: Date.new(2022, 10, 2),
        results: events,
        league:
      )

      expect(coordinator.results).to eq(events)
    end

    it 'prevents duplicate game result events' do
      events = [
        Basketball::Season::Result.new(
          game: games.first,
          home_score: 153,
          away_score: 151
        ),
        Basketball::Season::Result.new(
          game: games.first,
          home_score: 153,
          away_score: 151
        )
      ]

      error = described_class::AlreadyPlayedGameError

      expect do
        described_class.new(
          calendar:,
          current_date: Date.new(2022, 10, 2),
          results: events,
          league:
        )
      end.to raise_error(error)
    end

    it 'prevents unknown games' do
      events = [
        Basketball::Season::Result.new(
          game: make_regular(
            date: Date.new(2023, 3, 3),
            home_opponent: bunnies_opp,
            away_opponent: rabbits_opp,
            opponent_type:
          ),
          home_score: 153,
          away_score: 151
        )
      ]

      error = described_class::UnknownGameError

      expect do
        described_class.new(
          calendar:,
          current_date: Date.new(2022, 10, 2),
          results: events,
          league:
        )
      end.to raise_error(error)
    end

    it 'prevents current date from being before exhibition start date' do
      error = described_class::OutOfBoundsError

      expect do
        described_class.new(
          calendar:,
          current_date: Date.new(2022, 9, 30),
          league:
        )
      end.to raise_error(error)
    end

    it 'prevents current date from being after season end date' do
      error = described_class::OutOfBoundsError

      expect do
        described_class.new(
          calendar:,
          current_date: Date.new(2023, 4, 30),
          league:
        )
      end.to raise_error(error)
    end

    it 'handles loading partial date events' do
      events = games[0..-2].map do |game|
        Basketball::Season::Result.new(
          game:,
          home_score: 153,
          away_score: 151
        )
      end

      coordinator = described_class.new(
        calendar:,
        current_date: Date.new(2023, 1, 4),
        results: events,
        league:
      )

      expect(coordinator.results).to eq(events)
    end

    it 'prevents unplayed games in the past' do
      error = described_class::UnplayedGamesError

      expect do
        described_class.new(
          calendar:,
          current_date: Date.new(2022, 10, 2),
          league:
        )
      end.to raise_error(error)
    end

    it 'prevents played games in the future' do
      error = described_class::PlayedGamesError

      expect do
        described_class.new(
          calendar:,
          league:,
          current_date:,
          results: [
            Basketball::Season::Result.new(
              game: games.last,
              home_score: 153,
              away_score: 151
            )
          ]
        )
      end.to raise_error(error)
    end
  end

  describe '#sign!' do
    it 'calls league#sign!' do
      allow(league).to receive(:sign!)

      coordinator.sign!(team: bunnies, player: campy)

      expect(league).to have_received(:sign!).with(team: bunnies, player: campy)
    end
  end

  describe '#release!' do
    it 'calls league#release!' do
      allow(league).to receive(:release!)

      player = Basketball::Season::Player.new(id: 'P1', position:)

      coordinator.release!(player)

      expect(league).to have_received(:release!).with(player)
    end
  end

  describe '#current_games' do
    it 'handles loading partial date events' do
      events = games[0..-2].map do |game|
        Basketball::Season::Result.new(
          game:,
          home_score: 153,
          away_score: 151
        )
      end

      coordinator = described_class.new(
        calendar:,
        current_date: Date.new(2023, 1, 4),
        results: events,
        league:
      )

      expect(coordinator.current_games).to eq([games.last])
    end
  end

  describe '#exhibitions_for' do
    it 'returns all' do
      actual_games = coordinator.exhibitions_for

      expect(actual_games).to eq(exhibitions)
    end
  end

  describe '#regulars_for' do
    it 'returns all' do
      actual_games = coordinator.regulars_for

      expect(actual_games).to eq(regulars)
    end
  end

  describe '#games_for' do
    it 'returns all' do
      actual_games = coordinator.games_for

      expect(actual_games).to eq(games)
    end
  end

  describe '#done?' do
    it 'returns true when all games simulated' do
      coordinator.sim_rest!

      expect(coordinator.done?).to be true
    end

    it 'returns false when not all days simulated' do
      coordinator.sim!

      expect(coordinator.done?).to be false
    end
  end

  describe '#add!' do
    context 'when adding a season game' do
      it 'adds new game' do
        new_game = make_regular(
          date: Date.new(2023, 3, 4),
          home_opponent: bunnies,
          away_opponent: rabbits,
          opponent_type:
        )

        coordinator.add!(new_game)

        expect(coordinator.games).to include(new_game)
      end

      it 'prevents adding a game on the current date' do
        new_game = make_exhibition(
          date: Date.new(2022, 9, 29),
          home_opponent: bunnies,
          away_opponent: santas,
          opponent_type:
        )

        error = described_class::OutOfBoundsError

        expect { coordinator.add!(new_game) }.to raise_error(error)
      end

      it 'prevents adding a game before the current date' do
        new_game = make_exhibition(
          date: Date.new(2022, 9, 28),
          home_opponent: bunnies,
          away_opponent: santas,
          opponent_type:
        )

        error = described_class::OutOfBoundsError

        expect { coordinator.add!(new_game) }.to raise_error(error)
      end
    end
  end

  describe '#sim!' do
    it 'prevents games not matching current date' do
      coordinator = described_class.new(
        calendar:,
        current_date: Date.new(2022, 10, 1),
        league:
      )

      arena = BadArena.new(Date.new(2199, 1, 1))

      coordinator.send('arena=', arena)

      expect { coordinator.sim! }.to raise_error(described_class::GameNotCurrentError)
    end

    context 'when no days are specified' do
      it 'creates a game result event for each game' do
        coordinator.sim_rest!

        actual_games = coordinator.results.map(&:game)

        expect(actual_games).to eq(games)
      end
    end

    context 'when days are specified' do
      it 'creates a game result event for each game on the current day' do
        coordinator.sim!

        actual_games = coordinator.results.map(&:game)

        expect(actual_games).to eq([games.first])
      end
    end
  end

  specify '#total_days' do
    expect(coordinator.total_days).to eq((regular_end_date - exhibition_start_date).to_i)
  end

  specify '#days_left' do
    coordinator.sim!

    expect(coordinator.days_left).to eq((regular_end_date - exhibition_start_date).to_i - 1)
  end

  specify '#total_exhibitions' do
    expect(coordinator.total_exhibitions).to eq(2)
  end

  specify '#total_regulars' do
    expect(coordinator.total_regulars).to eq(2)
  end

  specify '#exhibitions_left' do
    coordinator.sim!

    expect(coordinator.exhibitions_left).to eq(1)
  end

  specify '#regulars_left' do
    34.times { coordinator.sim! }

    expect(coordinator.regulars_left).to eq(1)
  end
end
