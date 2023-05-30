# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::App::CoordinatorRepository do
  subject(:repository) { described_class.new }

  let(:coordinator) do
    Basketball::Season::Coordinator.new(
      calendar:,
      current_date:,
      league:
    ).tap do |coordinator|
      coordinator.send('arena=', PredictableArena.new)
    end
  end

  let(:calendar) do
    Basketball::Season::Calendar.new(
      preseason_start_date:,
      preseason_end_date:,
      season_start_date:,
      season_end_date:,
      games:
    )
  end

  let(:current_date)         { Date.new(2022, 10, 1) }
  let(:preseason_start_date) { Date.new(2022, 10, 1) }
  let(:preseason_end_date)   { Date.new(2022, 10, 14) }
  let(:season_start_date)    { Date.new(2022, 10, 16) }
  let(:season_end_date)      { Date.new(2023, 4, 29) }
  let(:teams)                { [bunnies, rabbits, santas, rizzos] }
  let(:league)               { Basketball::Org::League.new(teams:) }
  let(:path)                 { fixture_path('season', 'coordinator.json') }
  let(:fixture_hash)         { read_json_fixture('season', 'coordinator.json') }

  let(:bunnies) do
    Basketball::Org::Team.new(
      id: 'bunnies',
      players: [
        Basketball::Org::Player.new(id: 'P1', overall: 1),
        Basketball::Org::Player.new(id: 'P2', overall: 2)
      ]
    )
  end

  let(:rabbits) do
    Basketball::Org::Team.new(
      id: 'rabbits',
      players: [
        Basketball::Org::Player.new(id: 'P3', overall: 3),
        Basketball::Org::Player.new(id: 'P4', overall: 4)
      ]
    )
  end

  let(:santas) do
    Basketball::Org::Team.new(
      id: 'santas',
      players: [
        Basketball::Org::Player.new(id: 'P5', overall: 5)
      ]
    )
  end

  let(:rizzos) do
    Basketball::Org::Team.new(
      id: 'rizzos',
      players: [
        Basketball::Org::Player.new(id: 'P6', overall: 6)
      ]
    )
  end

  let(:bunnies_opp) { Basketball::Season::Opponent.new(id: 'bunnies') }
  let(:rabbits_opp) { Basketball::Season::Opponent.new(id: 'rabbits') }
  let(:santas_opp)  { Basketball::Season::Opponent.new(id: 'santas') }
  let(:rizzos_opp)  { Basketball::Season::Opponent.new(id: 'rizzos') }

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

  before do
    # sim a bunch of days to an exact date
    95.times { coordinator.sim! }
  end

  describe '#load' do
    subject(:actual_coordinator) { repository.load(path) }

    specify 'current_date' do
      expect(actual_coordinator.current_date).to eq(coordinator.current_date)
    end

    specify 'league' do
      expect(actual_coordinator.league).to eq(coordinator.league)
    end

    specify 'games' do
      expect(actual_coordinator.games).to eq(coordinator.games)
    end

    specify 'game result events' do
      expect(actual_coordinator.results).to eq(coordinator.results)
    end

    it 'sets coordinator id' do
      expect(actual_coordinator.id).to eq(path)
    end
  end

  describe '#save' do
    let(:filename) { "#{SecureRandom.uuid}.json" }
    let(:actual_hash) { read_json_temp_file(filename) }
    let(:rando_path) { temp_path(filename) }

    before { repository.save(rando_path, coordinator) }

    specify do
      expect(actual_hash).to eq(fixture_hash)
    end

    it 'sets coordinator id' do
      expect(coordinator.id).to eq(rando_path)
    end
  end
end
