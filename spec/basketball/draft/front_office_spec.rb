# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::FrontOffice do
  subject(:front_office) { described_class.new(id:, name:) }

  let(:id)   { 'p1234' }
  let(:name) { 'The Bunny Rabbits' }

  describe 'initialization' do
    it 'sets id' do
      expect(front_office.id).to eq(id.upcase)
    end

    it 'sets name' do
      expect(front_office.name).to eq(name)
    end
  end

  describe '#to_s' do
    it 'includes id' do
      expect(front_office.to_s).to include(id.upcase)
    end

    it 'includes name' do
      expect(front_office.to_s).to include(name)
    end
  end

  describe 'equality' do
    specify '==' do
      expect(front_office == described_class.new(id:)).to be true
    end
  end
end
