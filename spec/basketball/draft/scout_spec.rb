# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::Scout do
  let(:bob) { described_class.new }

  let(:mousey)        { Basketball::Season::Player.new(id: 'Mousey', position: center, overall: 1) }
  let(:funky_man)     { Basketball::Season::Player.new(id: 'Funky Man', position: center, overall: 2) }
  let(:moose_head)    { Basketball::Season::Player.new(id: 'Moose Head', position: power_forward, overall: 3) }
  let(:center)        { Basketball::Season::Position.new('C') }
  let(:power_forward) { Basketball::Season::Position.new('PF') }
  let(:players)       { [mousey, funky_man, moose_head] }

  describe '#top_for' do
    it 'sorts by overall descending' do
      expected = [moose_head, funky_man, mousey]
      actual   = bob.top_for(players:)

      expect(actual).to eq(expected)
    end

    it 'filters position' do
      expected = [moose_head]
      actual   = bob.top_for(players:, position: power_forward)

      expect(actual).to match_array(expected)
    end

    it 'filters excluded_positions' do
      expected = [funky_man, mousey]
      actual   = bob.top_for(players:, exclude_positions: [power_forward])

      expect(actual).to match_array(expected)
    end
  end
end
