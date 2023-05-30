# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::FrontOffice do
  subject(:front_office) { described_class.new(id:, fuzz:) }

  let(:id) { 'p1234' }
  let(:rando)             do
    Basketball::Org::Player.new(id: 'rando', overall: 12, position: Basketball::Org::Position.new('C'))
  end
  let(:the_dude) do
    Basketball::Org::Player.new(id: 'the dude', overall: 90, position: Basketball::Org::Position.new('C'))
  end
  let(:puffy) do
    Basketball::Org::Player.new(id: 'puffy', overall: 98, position: Basketball::Org::Position.new('C'))
  end
  let(:undrafted_players) { [the_dude, puffy, rando] }
  let(:top_two)           { [the_dude, puffy] }
  let(:drafted_players)   { [] }
  let(:pick)              { 3 }
  let(:round)             { 2 }
  let(:round_pick)        { 1 }
  let(:fuzz)              { 1 }

  let(:assessment) do
    Basketball::Draft::Assessment.new(
      undrafted_players:,
      drafted_players:,
      pick:,
      round:,
      round_pick:
    )
  end

  describe 'initialization' do
    it 'sets id' do
      expect(front_office.id).to eq(id)
    end
  end

  describe '#pick' do
    context 'with max fuzz of 1' do
      it 'returns the top overall player' do
        expect(front_office.pick(assessment)).to eq(puffy)
      end
    end

    context 'with max fuzz of 2' do
      it 'returns one of the top two overall players' do
        actual = front_office.pick(assessment)

        expect(top_two.include?(actual)).to be true
      end
    end
  end
end
