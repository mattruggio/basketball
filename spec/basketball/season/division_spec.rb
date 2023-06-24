# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::Division do
  subject(:division) { described_class.new(id:, teams:, name:) }

  let(:id)     { 'D-1' }
  let(:name)   { 'Midwest Division' }
  let(:teams)  { [clowns] }
  let(:clowns) { Basketball::Season::Team.new(id: 'Clowns') }

  describe 'initialization' do
    it 'sets id' do
      expect(division.id).to eq(id)
    end

    it 'sets name' do
      expect(division.name).to eq(name)
    end

    it 'sets teams' do
      expect(division.teams).to eq(teams)
    end

    it 'prevents dupe teams' do
      dupe_teams     = [clowns] * 5
      expected_error = Basketball::Season::TeamAlreadyRegisteredError

      expect { described_class.new(id:, teams: dupe_teams) }.to raise_error(expected_error)
    end
  end

  describe '#to_s' do
    it 'includes id' do
      expect(division.to_s).to include(id.upcase)
    end

    it 'includes teams' do
      teams.each do |team|
        expect(division.to_s).to include(team.to_s)
      end
    end

    it 'includes name' do
      expect(division.to_s).to include(name)
    end
  end

  describe 'equality' do
    specify '==' do
      expect(division == described_class.new(id:, teams:)).to be true
    end
  end
end
