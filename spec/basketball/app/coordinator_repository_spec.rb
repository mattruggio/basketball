# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::App::CoordinatorRepository do
  subject(:repository) { described_class.new(Basketball::App::FileStore.new) }

  let(:coordinator) do
    Basketball::Season::Coordinator.new(
      calendar:,
      current_date:
    ).tap do |coordinator|
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
  let(:league)                { Basketball::Org::League.new(conferences: [eastern]) }
  let(:path)                  { fixture_path('season', 'coordinator.json') }
  let(:fixture_hash)          { read_json_fixture('season', 'coordinator.json') }
  let(:eastern)               { Basketball::Org::Conference.new(id: 'Eastern', divisions: [midwest]) }
  let(:midwest)               { Basketball::Org::Division.new(id: 'Midwest', teams:) }

  let(:bunnies) do
    Basketball::Org::Team.new(
      id: 'bunnies',
      players: [
        Basketball::Org::Player.new(id: 'P1', overall: 1, position: Basketball::Org::Position.new('C')),
        Basketball::Org::Player.new(id: 'P2', overall: 2, position: Basketball::Org::Position.new('C'))
      ]
    )
  end

  let(:rabbits) do
    Basketball::Org::Team.new(
      id: 'rabbits',
      players: [
        Basketball::Org::Player.new(id: 'P3', overall: 3, position: Basketball::Org::Position.new('C')),
        Basketball::Org::Player.new(id: 'P4', overall: 4, position: Basketball::Org::Position.new('C'))
      ]
    )
  end

  let(:santas) do
    Basketball::Org::Team.new(
      id: 'santas',
      players: [
        Basketball::Org::Player.new(id: 'P5', overall: 5, position: Basketball::Org::Position.new('C'))
      ]
    )
  end

  let(:rizzos) do
    Basketball::Org::Team.new(
      id: 'rizzos',
      players: [
        Basketball::Org::Player.new(id: 'P6', overall: 6, position: Basketball::Org::Position.new('C'))
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
    95.times { coordinator.sim!(league) }
  end

  describe '#load' do
    subject(:actual_coordinator) { repository.load(path) }

    specify 'current_date' do
      expect(actual_coordinator.current_date).to eq(coordinator.current_date)
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
    let(:filename)    { "#{SecureRandom.uuid}.json" }
    let(:actual_hash) { read_json_temp_file(filename) }
    let(:rando_path)  { temp_path(filename) }

    before { repository.save(rando_path, coordinator) }

    specify 'deserialized data matches' do
      fixture_hash[:id] = rando_path

      expect(actual_hash).to eq(fixture_hash)
    end

    it 'sets coordinator id' do
      expect(coordinator.id).to eq(rando_path)
    end
  end
end
