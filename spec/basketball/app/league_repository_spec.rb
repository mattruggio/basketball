# frozen_string_literal: true

require 'spec_helper'

describe Basketball::App::LeagueRepository do
  subject(:repository) { described_class.new(store) }

  let(:key)      { '123-abc' }
  let(:store)    { Basketball::App::InMemoryStore.new }
  let(:league)   { Basketball::Org::League.new(conferences: [eastern]) }
  let(:eastern)  { Basketball::Org::Conference.new(id: 'Eastern', divisions: [midwest]) }
  let(:midwest)  { Basketball::Org::Division.new(id: 'Midwest', teams: [clowns]) }
  let(:clowns)   { Basketball::Org::Team.new(id: 'Clowns', players: [mousey]) }
  let(:bunnies)  { Basketball::Org::Team.new(id: 'Bunnies') }
  let(:mousey)   { Basketball::Org::Player.new(id: 'Mousey', overall: 98, position:) }
  let(:moose)    { Basketball::Org::Player.new(id: 'Moose', overall: 97, position:) }
  let(:position) { Basketball::Org::Position.new('C') }

  let(:json_hash) do
    {
      id: key,
      conferences: [
        {
          id: 'Eastern',
          divisions: [
            {
              id: 'Midwest',
              teams: [
                {
                  id: 'Clowns',
                  players: [
                    {
                      id: 'Mousey',
                      overall: 98,
                      position: 'C'
                    }
                  ]
                }
              ]
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

    it 'loads conference' do
      actual = repository.load(key)

      expect(actual.conferences).to eq([eastern])
    end

    it 'loads divisions' do
      actual = repository.load(key)

      expect(actual.divisions).to eq([midwest])
    end

    it 'loads teams' do
      actual = repository.load(key)

      expect(actual.teams).to eq([clowns])
    end

    it 'loads players' do
      actual = repository.load(key)

      expect(actual.players).to eq([mousey])
    end
  end
end
