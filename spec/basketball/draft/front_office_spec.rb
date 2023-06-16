# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::FrontOffice do
  subject(:ducks) { described_class.new(id:, name:) }

  let(:id)   { 'ducks' }
  let(:name) { 'The Ducks' }

  describe '#initialize' do
    it 'sets id' do
      expect(ducks.id).to eq(id)
    end

    it 'sets name' do
      expect(ducks.name).to eq(name)
    end

    it 'sets 12 prioritized positions' do
      expect(ducks.prioritized_positions.length).to eq(12)
    end
  end
end
