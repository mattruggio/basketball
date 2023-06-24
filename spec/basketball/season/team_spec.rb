# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Season::Team do
  subject(:team) { described_class.new(id:, players: [mousey], name:) }

  let(:id)         { 'p1234' }
  let(:name)       { 'Bunnies' }
  let(:mousey)     { Basketball::Season::Player.new(id: 'Mousey', position:) }
  let(:funky_man)  { Basketball::Season::Player.new(id: 'Funky Man', position:) }
  let(:moose_head) { Basketball::Season::Player.new(id: 'Moose Head', position:) }
  let(:position)   { Basketball::Season::Position.new('C') }

  describe 'initialization' do
    it 'sets id' do
      expect(team.id).to eq(id)
    end

    it 'sets name' do
      expect(team.name).to eq(name)
    end

    it 'sets players' do
      expect(team.players).to eq([mousey])
    end

    it 'prevents null players' do
      expect { described_class.new(id:, players: [nil]) }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s' do
    it 'includes ID' do
      expect(team.to_s).to include(team.id)
    end

    it 'includes players' do
      expect(team.to_s).to include(mousey.to_s)
    end

    it 'includes name' do
      expect(team.to_s).to include(name)
    end
  end

  describe '#sign!' do
    it 'cannot sign more than 18 players' do
      17.times { |i| team.sign!(Basketball::Season::Player.new(id: "p-#{i}", position:)) }

      error = described_class::MaxPlayerCountError

      expect(team.players.length).to eq(18)

      expect { team.sign!(Basketball::Season::Player.new(id: 'p-nope', position:)) }.to raise_error(error)
    end

    it 'prevents null players' do
      expect { team.sign!(nil) }.to raise_error(ArgumentError)
    end

    it 'adds player' do
      team.sign!(funky_man)

      expect(team.players).to eq([mousey, funky_man])
    end

    it 'prevents duplicate players' do
      team.sign!(funky_man)

      expect { team.sign!(funky_man) }.to raise_error(Basketball::Season::PlayerAlreadySignedError)
    end
  end

  describe '#signed?' do
    before do
      team.sign!(funky_man)
    end

    it 'returns true if player was signed' do
      expect(team.signed?(funky_man)).to be true
    end

    it 'returns false if player was signed' do
      expect(team.signed?(moose_head)).to be false
    end
  end

  describe '#release!' do
    it 'removes player' do
      team.release!(mousey)

      expect(team.players).to be_empty
    end

    it 'raises error if player is not signed' do
      expect { team.release!(funky_man) }.to raise_error(described_class::PlayerNotSignedError)
    end
  end
end
