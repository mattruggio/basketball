# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::Pick do
  subject(:event) do
    described_class.new(
      front_office: ducks,
      player: mickey,
      pick: 1,
      round: 1,
      round_pick: 1,
      auto:
    )
  end

  let(:auto)   { false }
  let(:ducks)  { Basketball::Draft::FrontOffice.new(id: 'ducks') }
  let(:mickey) { Basketball::Org::Player.new(id: 'mickey') }

  describe '#to_s' do
    context 'when auto event' do
      let(:auto) { true }

      it 'contains auto-picked' do
        expect(event.to_s).to include('auto-picked')
      end
    end

    context 'when manual event' do
      it 'contains picked' do
        expect(event.to_s).to include('picked')
      end

      it 'does not contain auto-picked' do
        expect(event.to_s).not_to include('auto-picked')
      end
    end
  end
end
