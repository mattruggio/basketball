# frozen_string_literal: true

require 'spec_helper'

describe Basketball::App::LeagueRepository do
  subject(:repository) { described_class.new(store) }

  let(:key)     { '123-abc' }
  let(:store)   { Basketball::App::InMemoryStore.new }
  let(:league)  { Basketball::Org::League.new(teams: [bunnies]) }
  let(:bunnies) { Basketball::Org::Team.new(id: 'Bunnies', players: [rabbit]) }
  let(:rabbit)  { Basketball::Org::Player.new(id: 'Rabbit', position: center, overall: 88) }
  let(:center)  { Basketball::Org::Position.new('C') }

  let(:json_hash) do
    {
      teams: [
        {
          id: 'Bunnies',
          players: [
            {
              id: 'Rabbit',
              overall: 88,
              position: 'C'
            }
          ]
        }
      ]
    }
  end

  describe '#to_h' do
    it 'converts league to hash' do
      repository.save(key, league)

      actual = json_parse(store.data[key])

      expect(actual).to eq(json_hash)
    end
  end

  describe '#load' do
    before do
      store.data[key] = json_hash.to_json
      league.send('id=', key)
    end

    it 'loads league' do
      actual = repository.load(key)

      expect(actual).to eq(league)
    end

    it 'loads team' do
      actual = repository.load(key)

      expect(actual.teams.first).to eq(bunnies)
    end

    it 'loads player' do
      actual = repository.load(key)

      expect(actual.teams.first.players.first).to eq(rabbit)
    end

    it 'loads player position' do
      actual = repository.load(key)

      expect(actual.teams.first.players.first.position).to eq(center)
    end
  end
end
