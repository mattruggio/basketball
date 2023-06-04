# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Org::Association do
  subject(:league) { Basketball::Org::Association.new(conferences: [eastern]) }

  let(:eastern)  { Basketball::Org::Conference.new(id: 'Eastern', divisions: [midwest]) }
  let(:midwest)  { Basketball::Org::Division.new(id: 'Midwest', teams: [clowns]) }
  let(:clowns)   { Basketball::Org::Team.new(id: 'Clowns', players: [mousey]) }
  let(:mousey)   { Basketball::Org::Player.new(id: 'Mousey', position:) }
  let(:position) { Basketball::Org::Position.new('C') }

  describe '#initialize' do
    it 'sets conferences' do
      expect(league.conferences).to eq([eastern])
    end

    it 'prevents dupe conferences' do
      dupe_conferences = [eastern, eastern]
      expected_error   = described_class::ConferenceAlreadyRegisteredError

      expect { described_class.new(conferences: dupe_conferences) }.to raise_error(expected_error)
    end

    it 'prevents dupe divisions across conferences' do
      divisions = [midwest]

      conferences = [
        Basketball::Org::Conference.new(
          id: 'Western',
          divisions:
        ),
        Basketball::Org::Conference.new(
          id: 'Eastern',
          divisions:
        )
      ]

      expected_error = Basketball::Org::DivisionAlreadyRegisteredError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end

    it 'prevents dupe teams across divisions' do
      team = Basketball::Org::Team.new(id: 'dupe-team')

      conferences = [
        Basketball::Org::Conference.new(
          id: 'Western',
          divisions: [
            Basketball::Org::Division.new(id: 'with-dupe-1', teams: [team])
          ]
        ),
        Basketball::Org::Conference.new(
          id: 'Eastern',
          divisions: [
            Basketball::Org::Division.new(id: 'with-dupe-2', teams: [team])
          ]
        )
      ]

      expected_error = Basketball::Org::TeamAlreadyRegisteredError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end

    it 'prevents dupe players across teams' do
      team = Basketball::Org::Team.new(id: 'dupe-team', players: [mousey])

      conferences = [
        Basketball::Org::Conference.new(
          id: 'Western',
          divisions: [
            Basketball::Org::Division.new(id: 'with-dupe-1', teams: [clowns])
          ]
        ),
        Basketball::Org::Conference.new(
          id: 'Eastern',
          divisions: [
            Basketball::Org::Division.new(id: 'with-dupe-2', teams: [team])
          ]
        )
      ]

      expected_error = Basketball::Org::PlayerAlreadySignedError

      expect { described_class.new(conferences:) }.to raise_error(expected_error)
    end
  end

  describe '#to_s' do
    it 'includes conferences' do
      expect(league.to_s).to include(eastern.to_s)
    end
  end

  specify '#divisions' do
    expect(league.divisions).to eq([midwest])
  end

  specify '#teams' do
    expect(league.teams).to eq([clowns])
  end

  specify '#players' do
    expect(league.players).to eq([mousey])
  end
end
