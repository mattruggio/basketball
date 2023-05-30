# frozen_string_literal: true

require 'spec_helper'

describe Basketball::App::RoomRepository do
  subject(:repository) { described_class.new }

  let(:room)          { Basketball::Draft::Room.new(rounds:, players:, front_offices:, events:) }
  let(:front_offices) { [ducks, eagles] }
  let(:players)       { [mickey, donald, daisy] }
  let(:rounds)        { 2 }
  let(:path)          { fixture_path('draft', 'basic_room.json') }
  let(:fixture_hash)  { read_json_fixture('draft', 'basic_room.json') }
  let(:ducks)         { Basketball::Draft::FrontOffice.new(id: 'ducks', fuzz: 2) }
  let(:eagles)        { Basketball::Draft::FrontOffice.new(id: 'eagles', fuzz: 5) }
  let(:mickey)        do
    Basketball::Org::Player.new(id: 'mickey', overall: 99, position: Basketball::Org::Position.new('C'))
  end
  let(:donald) do
    Basketball::Org::Player.new(id: 'donald', overall: 98, position: Basketball::Org::Position.new('C'))
  end
  let(:daisy) do
    Basketball::Org::Player.new(id: 'daisy', overall: 97, position: Basketball::Org::Position.new('C'))
  end

  let(:events) do
    [
      Basketball::Draft::Pick.new(
        front_office: ducks,
        pick: 1,
        round: 1,
        round_pick: 1,
        player: mickey,
        auto: true
      ),
      Basketball::Draft::Skip.new(
        front_office: eagles,
        pick: 2,
        round: 1,
        round_pick: 2
      ),
      Basketball::Draft::Pick.new(
        front_office: ducks,
        pick: 3,
        round: 2,
        round_pick: 1,
        player: donald
      )
    ]
  end

  describe '#load' do
    subject(:room) { repository.load(path) }

    specify 'rounds' do
      expect(room.rounds).to eq(2)
    end

    specify 'players' do
      expect(room.players).to eq(players)
    end

    specify 'front_offices' do
      expect(room.front_offices).to eq(front_offices)
    end

    specify 'events' do
      expect(room.events).to eq(events)
    end

    it 'sets room id' do
      expect(room.id).to eq(path)
    end
  end

  describe '#save' do
    let(:filename) { "#{SecureRandom.uuid}.json" }
    let(:actual_hash) { read_json_temp_file(filename) }
    let(:rando_path) { temp_path(filename) }

    before { repository.save(rando_path, room) }

    specify 'rounds' do
      expect(actual_hash[:rounds]).to eq(rounds)
    end

    specify 'players' do
      expect(actual_hash[:players]).to eq(fixture_hash[:players])
    end

    specify 'front_offices' do
      expect(actual_hash[:front_offices]).to eq(fixture_hash[:front_offices])
    end

    specify 'events' do
      expect(actual_hash[:events]).to eq(fixture_hash[:events])
    end

    it 'sets room id' do
      expect(room.id).to eq(rando_path)
    end
  end
end
