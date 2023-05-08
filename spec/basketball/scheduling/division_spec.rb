# frozen_string_literal: true

require 'spec_helper'
require 'scheduling_helper'

describe Basketball::Scheduling::Division do
  subject(:division) { described_class.new(id:, name:, teams:) }

  let(:id)    { 'D-1' }
  let(:name)  { 'Midwest' }
  let(:teams) { make_teams }
  let(:team)  { teams.first }

  describe 'initialization' do
    it 'sets id' do
      expect(division.id).to eq(id)
    end

    it 'sets teams' do
      expect(division.teams).to eq(teams)
    end

    it 'prevents dupe teams' do
      dupe_teams     = [team] * 5
      expected_error = Basketball::Scheduling::TeamAlreadyRegisteredError

      expect { described_class.new(id:, teams: dupe_teams) }.to raise_error(expected_error)
    end

    it 'prevents more than 5 teams' do
      teams          = make_teams(6)
      expected_error = Basketball::Scheduling::BadTeamsSizeError

      expect { described_class.new(id:, teams:) }.to raise_error(expected_error)
    end

    it 'prevents less than 5 teams' do
      teams          = make_teams(4)
      expected_error = Basketball::Scheduling::BadTeamsSizeError

      expect { described_class.new(id:, teams:) }.to raise_error(expected_error)
    end
  end

  describe '#to_s' do
    it 'includes id' do
      expect(division.to_s).to include(id.upcase)
    end

    it 'includes name' do
      expect(division.to_s).to include(name)
    end

    it 'includes teams' do
      teams.each do |team|
        expect(division.to_s).to include(team.to_s)
      end
    end
  end

  describe 'equality' do
    specify '==' do
      expect(division == described_class.new(id:, teams:)).to be true
    end
  end
end
