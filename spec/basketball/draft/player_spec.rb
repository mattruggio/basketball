# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::Player do
  subject(:player_with_no_last_name) do
    described_class.new(id:, first_name:, overall:, position:)
  end

  let(:player) do
    described_class.new(id:, first_name:, last_name:, overall:, position:)
  end
  let(:id)         { 'p1234' }
  let(:first_name) { '  Hops  ' }
  let(:last_name)  { '  The Bunny  ' }
  let(:overall)    { 34 }
  let(:position) { Basketball::Draft::Position.new('pf') }

  describe 'initialization' do
    it 'sets id' do
      expect(player.id).to eq(id.upcase)
    end

    it 'sets first_name' do
      expect(player.first_name).to eq(first_name)
    end

    it 'sets last_name' do
      expect(player.last_name).to eq(last_name)
    end

    it 'sets overall' do
      expect(player.overall).to eq(overall)
    end

    it 'sets position' do
      expect(player.position).to eq(position)
    end
  end

  describe '#full_name' do
    it 'includes stripped first name' do
      expect(player.full_name).to include(first_name.strip)
    end

    it 'includes stripped last name' do
      expect(player.full_name).to include(last_name.strip)
    end

    it 'strips whitespace with no last name' do
      expect(player_with_no_last_name.full_name).to eq(first_name.strip.to_s)
    end
  end

  describe '#to_s' do
    it 'includes id' do
      expect(player.to_s).to include(id.upcase)
    end

    it 'includes full_name' do
      expect(player.to_s).to include(player.full_name)
    end

    it 'includes position code' do
      expect(player.to_s).to include(position.code)
    end

    it 'includes overall' do
      expect(player.to_s).to include(overall.to_s)
    end
  end
end
