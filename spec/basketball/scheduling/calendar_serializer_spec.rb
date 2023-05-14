# frozen_string_literal: true

require 'spec_helper'
require 'scheduling_helper'

describe Basketball::Scheduling::CalendarSerializer do
  subject(:serializer) { described_class.new }

  let(:year)     { 2022 }
  let(:bunnies)  { make_team(id: 'bunnies', name: 'the bunnies') }
  let(:rabbits)  { make_team(id: 'rabbits', name: 'the rabbits') }
  let(:games)    { preseason_games + season_games }
  let(:calendar) { Basketball::Scheduling::Calendar.new(year: 2022, games:) }
  let(:contents) { read_fixture('scheduling', 'calendar.json') }

  let(:preseason_games) do
    [
      make_preseason_game(date: Date.parse('2022-10-01'), home_team: bunnies, away_team: rabbits),
      make_preseason_game(date: Date.parse('2022-10-02'), home_team: rabbits, away_team: bunnies)
    ]
  end

  let(:season_games) do
    [
      make_season_game(date: Date.parse('2022-11-03'), home_team: bunnies, away_team: rabbits),
      make_season_game(date: Date.parse('2023-01-04'), home_team: rabbits, away_team: bunnies)
    ]
  end

  specify '#to_hash' do
    actual_contents   = serializer.to_hash(calendar)
    expected_contents = JSON.parse(contents)

    expect(actual_contents).to eq(expected_contents)
  end

  specify '#from_hash' do
    actual_calendar = serializer.from_hash(JSON.parse(contents))

    expect(actual_calendar).to eq(calendar)
  end

  specify '#serialize' do
    actual_contents   = JSON.parse(serializer.serialize(calendar))
    expected_contents = JSON.parse(contents)

    expect(actual_contents).to eq(expected_contents)
  end

  specify '#deserialize' do
    actual_calendar = serializer.deserialize(contents)

    expect(actual_calendar).to eq(calendar)
  end
end
