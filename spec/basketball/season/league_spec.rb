# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::League do
  subject(:league) { described_class.new(conferences:) }

  let(:conferences) { make_conferences }

  describe 'initialization' do
    it 'sets conferences' do
      expect(league.conferences).to eq(conferences)
    end

    it 'prevents dupe conferences' do
      conference       = conferences.first
      dupe_conferences = [conference, conference]
      expected_error   = Basketball::Season::ConferenceAlreadyRegisteredError

      expect { described_class.new(conferences: dupe_conferences) }.to raise_error(expected_error)
    end

    it 'prevents dupe divisions across conferences' do
      divisions = conferences.first.divisions

      conferences = [
        Basketball::Season::Conference.new(
          id: 'Western',
          divisions:
        ),
        Basketball::Season::Conference.new(
          id: 'Eastern',
          divisions:
        )
      ]

      expected_error = Basketball::Season::DivisionAlreadyRegisteredError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end

    it 'prevents dupe teams across divisions' do
      team = Basketball::Season::Team.new(id: 'dupe-team')

      conferences = [
        Basketball::Season::Conference.new(
          id: 'Western',
          divisions: make_divisions(2) + [
            Basketball::Season::Division.new(id: 'with-dupe-1', teams: make_teams(4) + [team])
          ]
        ),
        Basketball::Season::Conference.new(
          id: 'Eastern',
          divisions: make_divisions(2) + [
            Basketball::Season::Division.new(id: 'with-dupe-2', teams: make_teams(4) + [team])
          ]
        )
      ]

      expected_error = Basketball::Season::TeamAlreadyRegisteredError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end

    it 'prevents more than 2 conferences' do
      conferences    = make_conferences(3)
      expected_error = Basketball::Season::BadConferencesSizeError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end

    it 'prevents less than 2 conference' do
      conferences    = make_conferences(1)
      expected_error = Basketball::Season::BadConferencesSizeError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end
  end

  describe '#to_s' do
    it 'includes conferences' do
      conferences.each do |conference|
        expect(league.to_s).to include(conference.to_s)
      end
    end
  end

  describe '#conference_for' do
    it 'returns conference' do
      team   = conferences.last.divisions.first.teams.last
      actual = league.conference_for(team)

      expect(actual).to eq(conferences.last)
    end

    it 'returns null for unknown team' do
      team   = make_teams(1).first
      actual = league.conference_for(team)

      expect(actual).to be_nil
    end
  end

  describe '#division_for' do
    it 'returns division' do
      team   = conferences.last.divisions.first.teams.last
      actual = league.division_for(team)

      expect(actual).to eq(conferences.last.divisions.first)
    end

    it 'returns null for unknown team' do
      team   = make_teams(1).first
      actual = league.division_for(team)

      expect(actual).to be_nil
    end
  end

  describe '#division_opponents_for' do
    it 'returns other teams' do
      team     = conferences.last.divisions.first.teams.last
      expected = conferences.last.divisions.first.teams - [team]
      actual   = league.division_opponents_for(team)

      expect(actual).to match_array(expected)
    end

    it 'returns null for unknown team' do
      team   = make_teams(1).first
      actual = league.division_opponents_for(team)

      expect(actual).to be_nil
    end
  end

  describe '#cross_division_opponents_for' do
    it 'returns other teams' do
      team     = conferences.last.divisions.first.teams.last
      expected = conferences.last.divisions[1..].flat_map(&:teams)
      actual   = league.cross_division_opponents_for(team)

      expect(actual).to match_array(expected)
    end

    it 'returns null for unknown team' do
      team   = make_teams(1).first
      actual = league.cross_division_opponents_for(team)

      expect(actual).to be_nil
    end
  end

  describe '#cross_conference_opponents_for' do
    it 'returns other teams' do
      team     = conferences.last.divisions.first.teams.last
      expected = conferences.first.divisions.flat_map(&:teams)
      actual   = league.cross_conference_opponents_for(team)

      expect(actual).to match_array(expected)
    end

    it 'returns null for unknown team' do
      team   = make_teams(1).first
      actual = league.cross_conference_opponents_for(team)

      expect(actual).to be_nil
    end
  end
end
