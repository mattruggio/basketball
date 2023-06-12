# frozen_string_literal: true

require 'spec_helper'

describe Basketball::App::StandingsRepository do
  subject(:repository) { described_class.new(store) }

  let(:id)            { '123' }
  let(:store)         { Basketball::App::InMemoryStore.new }
  let(:bunnies)       { Basketball::Org::Team.new(id: 'bunnies') }
  let(:rabbits)       { Basketball::Org::Team.new(id: 'rabbits') }
  let(:game)          { Basketball::Season::Game.new(date:, home_opponent:, away_opponent:) }
  let(:date)          { Date.new(2023, 1, 2) }
  let(:home_opponent) { Basketball::Org::Team.new(id: 'bunnies') }
  let(:away_opponent) { Basketball::Org::Team.new(id: 'rabbits') }
  let(:home_score)    { 2 }
  let(:away_score)    { 1 }
  let(:standings)     { Basketball::Season::Standings.new(records:) }
  let(:records)       { [bunny_record, rabbit_record] }
  let(:bunny_record)  { Basketball::Season::Record.new(id: bunnies.id, details: [bunny_detail]) }

  let(:bunny_detail) do
    Basketball::Season::Detail.new(
      date:,
      home: true,
      opponent: away_opponent,
      opponent_score: away_score,
      score: home_score
    )
  end

  let(:rabbit_record) { Basketball::Season::Record.new(id: rabbits.id, details: [rabbit_detail]) }

  let(:rabbit_detail) do
    Basketball::Season::Detail.new(
      date:,
      home: false,
      opponent: home_opponent,
      opponent_score: home_score,
      score: away_score
    )
  end

  let(:fixture_hash) do
    {
      id:,
      records: [
        {
          id: bunnies.id,
          details: [
            {
              date: date.to_s,
              home: true,
              opponent: rabbits.id,
              opponent_score: away_score,
              score: home_score
            }
          ]
        },
        {
          id: rabbits.id,
          details: [
            {
              date: date.to_s,
              home: false,
              opponent: bunnies.id,
              opponent_score: 2,
              score: 1
            }
          ]
        }
      ]
    }
  end

  describe '#save' do
    let(:actual_hash) { json_parse(store.data[id]) }

    before { repository.save(id, standings) }

    specify 'deserialized data matches' do
      fixture_hash[:id] = id

      expect(actual_hash).to eq(fixture_hash)
    end
  end

  describe '#load' do
    subject(:actual_standings) { repository.load(id) }

    before { repository.save(id, standings) }

    it 'loads id' do
      expect(actual_standings.id).to eq(id)
    end

    it 'loads records' do
      expect(actual_standings.records).to eq([bunny_record, rabbit_record])
    end

    it 'loads details' do
      expect(actual_standings.record_for(bunnies).details).to eq([bunny_detail])
      expect(actual_standings.record_for(rabbits).details).to eq([rabbit_detail])
    end
  end
end
