# frozen_string_literal: true

require 'spec_helper'
require 'scheduling_helper'

describe Basketball::Scheduling::LeagueSerializer do
  subject(:serializer) { described_class.new }

  let(:contents)       { read_fixture('scheduling', 'league.json') }

  let(:league) do
    make_league(
      conferences: [
        make_conference(
          id: 'c1',
          name: 'c1-n',
          divisions: [
            make_division(
              id: 'c1-d1',
              name: 'c1-d1-n',
              teams: [
                make_team(id: 'c1-d1-t1', name: 'c1-d1-t1-n'),
                make_team(id: 'c1-d1-t2', name: 'c1-d1-t2-n'),
                make_team(id: 'c1-d1-t3', name: 'c1-d1-t3-n'),
                make_team(id: 'c1-d1-t4', name: 'c1-d1-t4-n'),
                make_team(id: 'c1-d1-t5', name: 'c1-d1-t5-n')
              ]
            ),
            make_division(
              id: 'c1-d2',
              name: 'c1-d2-n',
              teams: [
                make_team(id: 'c1-d2-t1', name: 'c1-d2-t1-n'),
                make_team(id: 'c1-d2-t2', name: 'c1-d2-t2-n'),
                make_team(id: 'c1-d2-t3', name: 'c1-d2-t3-n'),
                make_team(id: 'c1-d2-t4', name: 'c1-d2-t4-n'),
                make_team(id: 'c1-d2-t5', name: 'c1-d2-t5-n')
              ]
            ),
            make_division(
              id: 'c1-d3',
              name: 'c1-d3-n',
              teams: [
                make_team(id: 'c1-d3-t1', name: 'c1-d3-t1-n'),
                make_team(id: 'c1-d3-t2', name: 'c1-d3-t2-n'),
                make_team(id: 'c1-d3-t3', name: 'c1-d3-t3-n'),
                make_team(id: 'c1-d3-t4', name: 'c1-d3-t4-n'),
                make_team(id: 'c1-d3-t5', name: 'c1-d3-t5-n')
              ]
            )
          ]
        ),
        make_conference(
          id: 'c2',
          name: 'c2-n',
          divisions: [
            make_division(
              id: 'c2-d1',
              name: 'c2-d1-n',
              teams: [
                make_team(id: 'c2-d1-t1', name: 'c2-d1-t1-n'),
                make_team(id: 'c2-d1-t2', name: 'c2-d1-t2-n'),
                make_team(id: 'c2-d1-t3', name: 'c2-d1-t3-n'),
                make_team(id: 'c2-d1-t4', name: 'c2-d1-t4-n'),
                make_team(id: 'c2-d1-t5', name: 'c2-d1-t5-n')
              ]
            ),
            make_division(
              id: 'c2-d2',
              name: 'c2-d2-n',
              teams: [
                make_team(id: 'c2-d2-t1', name: 'c2-d2-t1-n'),
                make_team(id: 'c2-d2-t2', name: 'c2-d2-t2-n'),
                make_team(id: 'c2-d2-t3', name: 'c2-d2-t3-n'),
                make_team(id: 'c2-d2-t4', name: 'c2-d2-t4-n'),
                make_team(id: 'c2-d2-t5', name: 'c2-d2-t5-n')
              ]
            ),
            make_division(
              id: 'c2-d3',
              name: 'c2-d3-n',
              teams: [
                make_team(id: 'c2-d3-t1', name: 'c2-d3-t1-n'),
                make_team(id: 'c2-d3-t2', name: 'c2-d3-t2-n'),
                make_team(id: 'c2-d3-t3', name: 'c2-d3-t3-n'),
                make_team(id: 'c2-d3-t4', name: 'c2-d3-t4-n'),
                make_team(id: 'c2-d3-t5', name: 'c2-d3-t5-n')
              ]
            )
          ]
        )
      ]
    )
  end

  describe '#deserialize' do
    it 'deserializes conferences' do
      actual_league = serializer.deserialize(contents)

      expect(actual_league.conferences).to eq(league.conferences)
    end
  end

  describe '#serialize' do
    it 'serializes conferences' do
      actual_contents = JSON.parse(serializer.serialize(league))

      expect(actual_contents).to eq(JSON.parse(contents))
    end
  end
end
