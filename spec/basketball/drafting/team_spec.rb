# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Drafting::Team do
  subject(:team) do
    described_class.new(id:, name:)
  end

  let(:id)   { 'p1234' }
  let(:name) { 'The Bunny Rabbits' }

  describe 'initialization' do
    it 'sets id' do
      expect(team.id).to eq(id.upcase)
    end

    it 'sets name' do
      expect(team.name).to eq(name)
    end
  end

  describe '#to_s' do
    it 'includes id' do
      expect(team.to_s).to include(id.upcase)
    end

    it 'includes name' do
      expect(team.to_s).to include(name)
    end
  end
end
