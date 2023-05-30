# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Org::League do
  subject(:league) { described_class.new(teams: [chunky_monkeys, fantastics]) }

  let(:chunky_monkeys) { Basketball::Org::Team.new(id: 'Chunky Monkeys', players: [mousey]) }
  let(:fantastics)     { Basketball::Org::Team.new(id: 'Fantastics', players: [funky_man]) }
  let(:clowns)         { Basketball::Org::Team.new(id: 'Clowns') }
  let(:mousey)         { Basketball::Org::Player.new(id: 'Mousey') }
  let(:funky_man)      { Basketball::Org::Player.new(id: 'Funky Man') }
  let(:moose_head)     { Basketball::Org::Player.new(id: 'Moose Head') }

  describe '#initialize' do
    it 'sets teams' do
      expect(league.teams).to eq([chunky_monkeys, fantastics])
    end

    it 'prevents dupe teams' do
      error = described_class::TeamAlreadyRegisteredError

      expect { described_class.new(teams: [chunky_monkeys, chunky_monkeys]) }.to raise_error(error)
    end

    it 'prevents null teams' do
      expect { described_class.new(teams: [nil]) }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s' do
    it 'includes teams' do
      expect(league.to_s).to include(chunky_monkeys.to_s)
    end
  end

  describe '#registered?' do
    it 'returns true' do
      expect(league.registered?(chunky_monkeys)).to be true
    end

    it 'returns false' do
      expect(league.registered?(clowns)).to be false
    end
  end

  describe '#register!' do
    it 'adds team' do
      league.register!(clowns)

      expect(league.teams).to eq([chunky_monkeys, fantastics, clowns])
    end

    it 'prevents duplicate teams' do
      expect { league.register!(chunky_monkeys) }.to raise_error(described_class::TeamAlreadyRegisteredError)
    end

    it 'prevents null team' do
      expect { league.register!(nil) }.to raise_error(ArgumentError)
    end
  end

  specify '#players returns all players' do
    expect(league.players).to eq([mousey, funky_man])
  end

  describe '#signed?' do
    it 'returns true' do
      expect(league.signed?(mousey)).to be true
    end

    it 'returns false' do
      expect(league.signed?(moose_head)).to be false
    end
  end

  describe '#sign!' do
    it 'adds player to team' do
      league.sign!(player: moose_head, team: fantastics)

      expect(fantastics.players).to include(moose_head)
    end

    it 'prevents null player' do
      expect { league.sign!(player: nil, team: chunky_monkeys) }.to raise_error(ArgumentError)
    end

    it 'prevents null team' do
      expect { league.sign!(player: moose_head, team: nil) }.to raise_error(ArgumentError)
    end

    it 'prevents signing players to an unregistered team' do
      error = described_class::UnregisteredTeamError

      expect { league.sign!(player: moose_head, team: clowns) }.to raise_error(error)
    end

    it 'prevents double-signing players' do
      error = Basketball::Org::PlayerAlreadySignedError

      expect { league.sign!(player: mousey, team: chunky_monkeys) }.to raise_error(error)
    end
  end
end
