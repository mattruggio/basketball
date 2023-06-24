# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Common::Player do
  let(:player) do
    described_class.new(
      id:,
      overall:,
      position:,
      first_name:,
      last_name:
    )
  end

  let(:id)         { 'p1234' }
  let(:overall)    { 95 }
  let(:position)   { Basketball::Common::Position.new('C') }
  let(:first_name) { 'Bugs' }
  let(:last_name)  { 'Bunny' }

  describe '#initialize' do
    it 'sets id' do
      expect(player.id).to eq(id)
    end

    it 'sets overall' do
      expect(player.overall).to eq(overall)
    end

    it 'sets position' do
      expect(player.position).to eq(position)
    end

    it 'sets first_name' do
      expect(player.first_name).to eq(first_name)
    end

    it 'sets last_name' do
      expect(player.last_name).to eq(last_name)
    end
  end

  describe '#to_s' do
    it 'contains overall' do
      expect(player.to_s).to include(overall.to_s)
    end

    it 'contains position' do
      expect(player.to_s).to include(position.to_s)
    end

    it 'contains full name' do
      expect(player.to_s).to include("#{first_name} #{last_name}")
    end
  end
end
