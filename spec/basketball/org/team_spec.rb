# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Org::Team do
  subject(:team)   { described_class.new(id:, players: [mousey]) }

  let(:id)         { 'p1234' }
  let(:mousey)     { Basketball::Org::Player.new(id: 'Mousey', position: Basketball::Org::Position.new('C')) }
  let(:funky_man)  { Basketball::Org::Player.new(id: 'Funky Man', position: Basketball::Org::Position.new('C')) }
  let(:moose_head) { Basketball::Org::Player.new(id: 'Moose Head', position: Basketball::Org::Position.new('C')) }

  describe 'initialization' do
    it 'sets id' do
      expect(team.id).to eq(id)
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
  end

  describe '#sign!' do
    it 'prevents null players' do
      expect { team.sign!(nil) }.to raise_error(ArgumentError)
    end

    it 'adds player' do
      team.sign!(funky_man)

      expect(team.players).to eq([mousey, funky_man])
    end

    it 'prevents duplicate players' do
      team.sign!(funky_man)

      expect { team.sign!(funky_man) }.to raise_error(Basketball::Org::PlayerAlreadySignedError)
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
end
