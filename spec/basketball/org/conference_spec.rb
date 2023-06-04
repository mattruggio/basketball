# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Org::Conference do
  subject(:conference) { described_class.new(id:, divisions:) }

  let(:id)        { 'C-1' }
  let(:divisions) { [midwest] }
  let(:eastern)   { described_class.new(id: 'Eastern', divisions: [midwest]) }
  let(:midwest)   { Basketball::Org::Division.new(id: 'Midwest', teams: [clowns]) }
  let(:clowns)    { Basketball::Org::Team.new(id: 'Clowns') }

  describe 'initialization' do
    it 'sets id' do
      expect(conference.id).to eq(id)
    end

    it 'sets divisions' do
      expect(conference.divisions).to eq(divisions)
    end

    it 'prevents dupe divisions' do
      dupe_divisions = [midwest] * 3
      expected_error = Basketball::Org::DivisionAlreadyRegisteredError

      expect { described_class.new(id:, divisions: dupe_divisions) }.to raise_error(expected_error)
    end

    it 'prevents divisions with dupe teams' do
      team = Basketball::Org::Team.new(id: 'dupe-team')

      dupe_divisions = [
        Basketball::Org::Division.new(id: 'with-dupe-1', teams: [team]),
        Basketball::Org::Division.new(id: 'with-dupe-2', teams: [team])
      ]

      expected_error = Basketball::Org::TeamAlreadyRegisteredError

      expect { described_class.new(id:, divisions: dupe_divisions) }.to raise_error(expected_error)
    end
  end

  describe '#to_s' do
    it 'includes id' do
      expect(conference.to_s).to include(id.upcase)
    end

    it 'includes divisions' do
      divisions.each do |division|
        expect(conference.to_s).to include(division.to_s)
      end
    end
  end

  describe 'equality' do
    specify '==' do
      expect(conference == described_class.new(id:, divisions:)).to be true
    end
  end
end
