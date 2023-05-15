# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::LeagueSerializer do
  subject(:serializer) { described_class.new }

  let(:contents) { read_fixture('season', 'league.json') }

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

  specify '#to_hash' do
    actual_contents = serializer.to_hash(league)

    expect(actual_contents).to eq(JSON.parse(contents))
  end

  specify '#from_hash' do
    actual_league = serializer.from_hash(JSON.parse(contents))

    expect(actual_league.conferences).to eq(league.conferences)
  end

  specify '#deserialize' do
    actual_league = serializer.deserialize(contents)

    expect(actual_league.conferences).to eq(league.conferences)
  end

  specify '#serialize' do
    actual_contents = JSON.parse(serializer.serialize(league))

    expect(actual_contents).to eq(JSON.parse(contents))
  end
end
