# frozen_string_literal: true

require 'spec_helper'
require 'scheduling_helper'

describe Basketball::Scheduling::League do
  subject(:league) { described_class.new(conferences:) }

  let(:conferences) { make_conferences }

  describe 'initialization' do
    it 'sets conferences' do
      expect(league.conferences).to eq(conferences)
    end

    it 'prevents dupe conferences' do
      conference       = conferences.first
      dupe_conferences = [conference, conference]
      expected_error   = Basketball::Scheduling::ConferenceAlreadyRegisteredError

      expect { described_class.new(conferences: dupe_conferences) }.to raise_error(expected_error)
    end

    it 'prevents dupe divisions across conferences' do
      divisions = conferences.first.divisions

      conferences = [
        Basketball::Scheduling::Conference.new(
          id: 'Western',
          divisions:
        ),
        Basketball::Scheduling::Conference.new(
          id: 'Eastern',
          divisions:
        )
      ]

      expected_error = Basketball::Scheduling::DivisionAlreadyRegisteredError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end

    it 'prevents dupe teams across divisions' do
      team = Basketball::Scheduling::Team.new(id: 'dupe-team')

      conferences = [
        Basketball::Scheduling::Conference.new(
          id: 'Western',
          divisions: make_divisions(2) + [
            Basketball::Scheduling::Division.new(id: 'with-dupe-1', teams: make_teams(4) + [team])
          ]
        ),
        Basketball::Scheduling::Conference.new(
          id: 'Eastern',
          divisions: make_divisions(2) + [
            Basketball::Scheduling::Division.new(id: 'with-dupe-2', teams: make_teams(4) + [team])
          ]
        )
      ]

      expected_error = Basketball::Scheduling::TeamAlreadyRegisteredError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end

    it 'prevents more than 2 conferences' do
      conferences    = make_conferences(3)
      expected_error = Basketball::Scheduling::BadConferencesSizeError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end

    it 'prevents less than 2 conference' do
      conferences    = make_conferences(1)
      expected_error = Basketball::Scheduling::BadConferencesSizeError

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
end
