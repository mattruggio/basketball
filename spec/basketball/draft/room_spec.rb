# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::Room do
  subject(:room) { described_class.new(rounds:, players:, front_offices:, events:) }

  let(:rounds) { 1 }
  let(:events) { [] }

  # Front Offices
  let(:ducks)         { Basketball::Draft::FrontOffice.new(id: 'ducks') }
  let(:eagles)        { Basketball::Draft::FrontOffice.new(id: 'eagles') }
  let(:front_offices) { [ducks, eagles] }

  # Players
  let(:mickey)  { Basketball::Draft::Player.new(id: 'mickey', position: Basketball::Draft::Position.new('C')) }
  let(:donald)  { Basketball::Draft::Player.new(id: 'donald', position: Basketball::Draft::Position.new('C')) }
  let(:daisy)   { Basketball::Draft::Player.new(id: 'daisy', position: Basketball::Draft::Position.new('C')) }
  let(:players) { [mickey, donald, daisy] }

  describe '#initialize' do
    it 'sets rounds' do
      expect(room.rounds).to eq(rounds)
    end

    describe 'events' do
      it 'sets' do
        events = [
          Basketball::Draft::Pick.new(front_office: ducks, player: mickey, id: 1, round: 1, round_pick: 1)
        ]

        room = described_class.new(rounds:, players:, front_offices:, events:)

        expect(room.events).to eq(events)
      end

      it 'prevents events over limit' do
        events = [
          Basketball::Draft::Pick.new(front_office: ducks, player: mickey, id: 1, round: 1, round_pick: 1),
          Basketball::Draft::Pick.new(front_office: eagles, player: donald, id: 2, round: 1, round_pick: 2),
          Basketball::Draft::Pick.new(front_office: ducks, player: daisy, id: 3, round: 2, round_pick: 1)
        ]

        expect do
          described_class.new(rounds:, players:, front_offices:, events:)
        end.to raise_error(described_class::EndOfDraftError)
      end

      it 'prevents pick values out of order' do
        events = [
          Basketball::Draft::Pick.new(front_office: ducks, player: mickey, id: 2, round: 1, round_pick: 1)
        ]

        error = described_class::EventOutOfOrderError

        expect { described_class.new(rounds:, players:, front_offices:, events:) }.to raise_error(error)
      end

      it 'prevents round values out of order' do
        events = [
          Basketball::Draft::Pick.new(front_office: ducks, player: mickey, id: 1, round: 2, round_pick: 1)
        ]

        error = described_class::EventOutOfOrderError

        expect { described_class.new(rounds:, players:, front_offices:, events:) }.to raise_error(error)
      end

      it 'prevents round pick values out of order' do
        events = [
          Basketball::Draft::Pick.new(front_office: ducks, player: mickey, id: 1, round: 1, round_pick: 2)
        ]

        error = described_class::EventOutOfOrderError

        expect { described_class.new(rounds:, players:, front_offices:, events:) }.to raise_error(error)
      end
    end

    describe 'front_offices' do
      it 'sets' do
        expect(room.front_offices).to eq(front_offices)
      end

      it 'prevents nulls' do
        expect { described_class.new(rounds:, players:, front_offices: [nil]) }.to raise_error(ArgumentError)
      end

      it 'prevents duplicates' do
        error = described_class::FrontOfficeAlreadyRegisteredError

        expect { described_class.new(rounds:, players:, front_offices: [ducks, ducks]) }.to raise_error(error)
      end
    end
  end

  describe '#remaining_picks' do
    specify 'with no picks' do
      expect(room.remaining_picks).to eq(2)
    end

    specify 'with some picks' do
      room.sim!

      expect(room.remaining_picks).to eq(1)
    end

    specify 'with all picks' do
      room.sim_rest!

      expect(room.remaining_picks).to eq(0)
    end
  end

  describe 'players' do
    it 'sets' do
      expect(room.players).to eq(players)
    end

    it 'prevents nulls' do
      expect { described_class.new(rounds:, players: [nil], front_offices:) }.to raise_error(ArgumentError)
    end

    it 'prevents duplicates' do
      error = described_class::PlayerAlreadyAddedError

      expect { described_class.new(rounds:, players: [mickey, mickey], front_offices:) }.to raise_error(error)
    end
  end

  describe '#sim_rest!' do
    it 'sims until the end of the draft' do
      room.sim_rest!

      expect(room.done?).to be true
    end

    it 'returns events' do
      events = room.sim_rest!

      expect(events.length).to eq(2)
    end
  end

  describe '#drafted_players' do
    it 'returns all players that have been selected' do
      room.sim_rest!

      actual = room.drafted_players
      expected = room.player_events.map(&:player)

      expect(actual).to eq(expected)
    end

    it 'returns all players selected by a specific front office' do
      room.sim_rest!

      actual   = room.drafted_players(ducks)
      expected = room.player_events.select { |e| e.front_office == ducks }.map(&:player)

      expect(actual).to eq(expected)
    end
  end

  describe '#skip!' do
    describe 'round 1 pick 1' do
      let(:event) { room.skip! }

      it 'Skip instance' do
        expect(event).to be_a(Basketball::Draft::Skip)
      end

      specify 'id' do
        expect(event.id).to eq(1)
      end

      specify 'round' do
        expect(event.round).to eq(1)
      end

      specify 'round pick' do
        expect(event.round_pick).to eq(1)
      end
    end

    describe 'round 1 pick 2' do
      let(:event) do
        room.skip!
        room.skip!
      end

      specify 'Skip instance' do
        expect(event).to be_a(Basketball::Draft::Skip)
      end

      specify 'id' do
        expect(event.id).to eq(2)
      end

      specify 'round' do
        expect(event.round).to eq(1)
      end

      specify 'round pick' do
        expect(event.round_pick).to eq(2)
      end
    end

    describe 'after draft over' do
      let(:event) do
        room.skip!
        room.skip!
        room.skip!
      end

      specify 'returns nil' do
        expect(event).to be_nil
      end
    end
  end

  describe '#sim!' do
    describe 'round 1 pick 1' do
      let(:event) { room.sim! }

      it 'Pick instance' do
        expect(event).to be_a(Basketball::Draft::Pick)
      end

      specify 'auto' do
        expect(event.auto).to be true
      end

      specify 'id' do
        expect(event.id).to eq(1)
      end

      specify 'round' do
        expect(event.round).to eq(1)
      end

      specify 'round pick' do
        expect(event.round_pick).to eq(1)
      end
    end

    describe 'round 1 pick 2' do
      let(:event) do
        room.sim!
        room.sim!
      end

      specify 'Skip instance' do
        expect(event).to be_a(Basketball::Draft::Pick)
      end

      specify 'auto' do
        expect(event.auto).to be true
      end

      specify 'id' do
        expect(event.id).to eq(2)
      end

      specify 'round' do
        expect(event.round).to eq(1)
      end

      specify 'round pick' do
        expect(event.round_pick).to eq(2)
      end
    end

    describe 'after draft over' do
      let(:event) do
        room.sim!
        room.sim!
        room.sim!
      end

      specify 'returns nil' do
        expect(event).to be_nil
      end
    end
  end

  describe '#pick!' do
    it 'prevents duplicate players picked' do
      error = described_class::AlreadyPickedError

      room.pick!(mickey)

      expect { room.pick!(mickey) }.to raise_error(error)
    end

    describe 'round 1 pick 1' do
      let(:event) { room.pick!(mickey) }

      it 'Pick instance' do
        expect(event).to be_a(Basketball::Draft::Pick)
      end

      specify 'auto' do
        expect(event.auto).to be false
      end

      specify 'player' do
        expect(event.player).to eq(mickey)
      end

      specify 'id' do
        expect(event.id).to eq(1)
      end

      specify 'round' do
        expect(event.round).to eq(1)
      end

      specify 'round pick' do
        expect(event.round_pick).to eq(1)
      end
    end

    describe 'round 1 pick 2' do
      let(:event) do
        room.pick!(mickey)
        room.pick!(donald)
      end

      specify 'Skip instance' do
        expect(event).to be_a(Basketball::Draft::Pick)
      end

      specify 'auto' do
        expect(event.auto).to be false
      end

      specify 'player' do
        expect(event.player).to eq(donald)
      end

      specify 'id' do
        expect(event.id).to eq(2)
      end

      specify 'round' do
        expect(event.round).to eq(1)
      end

      specify 'round pick' do
        expect(event.round_pick).to eq(2)
      end
    end

    describe 'after draft over' do
      let(:event) do
        room.pick!(mickey)
        room.pick!(donald)
        room.pick!(daisy)
      end

      specify 'returns nil' do
        expect(event).to be_nil
      end
    end
  end
end
