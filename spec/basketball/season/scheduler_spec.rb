# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::Scheduler do
  subject(:scheduler) { described_class.new }

  let(:league) { read_league_fixture('season', 'league.json') }
  let(:year)   { 2023 }

  describe '#schedule' do
    context 'when given incorrectly sized league' do
      it 'prevents more than 2 conferences per league' do
        bad_league     = Basketball::Org::League.new(conferences: make_conferences(3))
        expected_error = described_class::BadConferencesSizeError

        expect { scheduler.schedule(year:, league: bad_league) }.to raise_error(expected_error)
      end

      it 'prevents less than 2 conferences per league' do
        bad_league     = Basketball::Org::League.new(conferences: make_conferences(1))
        expected_error = described_class::BadConferencesSizeError

        expect { scheduler.schedule(year:, league: bad_league) }.to raise_error(expected_error)
      end

      it 'prevents more than 3 divisions per conference' do
        bad_conference = Basketball::Org::Conference.new(id: 'bad', divisions: make_divisions(4))
        bad_league     = Basketball::Org::League.new(conferences: make_conferences(1) + [bad_conference])
        expected_error = described_class::BadDivisionsSizeError

        expect { scheduler.schedule(year:, league: bad_league) }.to raise_error(expected_error)
      end

      it 'prevents less than 3 divisions per conference' do
        bad_conference = Basketball::Org::Conference.new(id: 'bad', divisions: make_divisions(2))
        bad_league     = Basketball::Org::League.new(conferences: make_conferences(1) + [bad_conference])
        expected_error = described_class::BadDivisionsSizeError

        expect { scheduler.schedule(year:, league: bad_league) }.to raise_error(expected_error)
      end

      it 'prevents more than 5 teams per division' do
        bad_division   = Basketball::Org::Division.new(id: 'bad-d', teams: make_teams(6))
        bad_conference = Basketball::Org::Conference.new(id: 'bad-c', divisions: make_divisions(2) + [bad_division])
        bad_league     = Basketball::Org::League.new(conferences: make_conferences(1) + [bad_conference])
        expected_error = described_class::BadTeamsSizeError

        expect { scheduler.schedule(year:, league: bad_league) }.to raise_error(expected_error)
      end

      it 'prevents less than 5 teams per division' do
        bad_division   = Basketball::Org::Division.new(id: 'bad-d', teams: make_teams(4))
        bad_conference = Basketball::Org::Conference.new(id: 'bad-c', divisions: make_divisions(2) + [bad_division])
        bad_league     = Basketball::Org::League.new(conferences: make_conferences(1) + [bad_conference])
        expected_error = described_class::BadTeamsSizeError

        expect { scheduler.schedule(year:, league: bad_league) }.to raise_error(expected_error)
      end
    end

    specify 'all teams play between 3 and 6 exhibition games' do
      calendar = scheduler.schedule(year:, league:)

      league.teams.each do |team|
        count = calendar.exhibitions_for(opponent: team).length

        expect(count).to be_between(3, 6), "#{team} only plays #{count} exhibition games"
      end
    end

    specify 'all teams play 82 season games' do
      calendar = scheduler.schedule(year:, league:)

      league.teams.each do |team|
        count = calendar.regulars_for(opponent: team).length

        expect(count).to eq(82), "#{team} plays #{count} season games"
      end
    end
  end
end
