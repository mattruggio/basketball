# frozen_string_literal: true

require 'spec_helper'
require 'scheduling_helper'

describe Basketball::Scheduling::Conference do
  subject(:conference) { described_class.new(id:, name:, divisions:) }

  let(:id)        { 'C-1' }
  let(:name)      { 'Eastern' }
  let(:divisions) { make_divisions }
  let(:division)  { divisions.first }

  describe 'initialization' do
    it 'sets id' do
      expect(conference.id).to eq(id)
    end

    it 'sets divisions' do
      expect(conference.divisions).to eq(divisions)
    end

    it 'prevents dupe divisions' do
      dupe_divisions = [division] * 3
      expected_error = Basketball::Scheduling::DivisionAlreadyRegisteredError

      expect { described_class.new(id:, divisions: dupe_divisions) }.to raise_error(expected_error)
    end

    it 'prevents divisions with dupe teams' do
      team = Basketball::Scheduling::Team.new(id: 'dupe-team')

      dupe_divisions = make_divisions(1) + [
        Basketball::Scheduling::Division.new(id: 'with-dupe-1', teams: make_teams(4) + [team]),
        Basketball::Scheduling::Division.new(id: 'with-dupe-2', teams: make_teams(4) + [team])
      ]

      expected_error = Basketball::Scheduling::TeamAlreadyRegisteredError

      expect { described_class.new(id:, divisions: dupe_divisions) }.to raise_error(expected_error)
    end

    it 'prevents more than 3 divisions' do
      divisions      = make_divisions(4)
      expected_error = Basketball::Scheduling::BadDivisionsSizeError

      expect { described_class.new(id:, divisions:) }.to raise_error(expected_error)
    end

    it 'prevents less than 3 divisions' do
      divisions      = make_divisions(2)
      expected_error = Basketball::Scheduling::BadDivisionsSizeError

      expect { described_class.new(id:, divisions:) }.to raise_error(expected_error)
    end
  end

  describe '#to_s' do
    it 'includes id' do
      expect(conference.to_s).to include(id.upcase)
    end

    it 'includes name' do
      expect(conference.to_s).to include(name)
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
