# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Scheduling::CLI do
  let(:input_path)          { fixture_path(dir, 'league.json') }
  let(:io)                  { StringIO.new }
  let(:prefix)              { "#{SecureRandom.uuid}-" }
  let(:dir)                 { File.join('scheduling') }
  let(:league_serializer)   { Basketball::Scheduling::LeagueSerializer.new }
  let(:calendar_serializer) { Basketball::Scheduling::CalendarSerializer.new }
  let(:calendar_path)       { fixture_path(dir, 'full_calendar.json') }

  describe 'league generation' do
    it 'has two conferences' do
      output_path = File.join(TEMP_DIR, dir, "#{prefix}.json")
      args        = ['-o', output_path]

      described_class.new(args:, io:).invoke!

      league = league_serializer.deserialize(File.read(output_path))

      expect(league.conferences.length).to eq(2)
    end

    it 'has 6 divisions' do
      output_path = File.join(TEMP_DIR, dir, "#{prefix}.json")
      args        = ['-o', output_path]

      described_class.new(args:, io:).invoke!

      league = league_serializer.deserialize(File.read(output_path))

      expect(league.divisions.length).to eq(6)
    end

    it 'has 30 teams' do
      output_path = File.join(TEMP_DIR, dir, "#{prefix}league.json")
      args        = ['-o', output_path]

      described_class.new(args:, io:).invoke!

      league = league_serializer.deserialize(File.read(output_path))

      expect(league.teams.length).to eq(30)
    end
  end

  describe 'calendar generation' do
    it 'all league teams get assigned 4-6 preseason games' do
      output_path = File.join(TEMP_DIR, dir, "#{prefix}calendar.json")
      args        = ['-i', input_path, '-o', output_path]
      league      = league_serializer.deserialize(File.read(input_path))

      described_class.new(args:, io:).invoke!

      calendar = calendar_serializer.deserialize(File.read(output_path))

      league.teams.each do |team|
        expect(calendar.preseason_games_for(team:).length).to be_between(4, 6)
      end
    end

    it 'all league teams get assigned 82 season games' do
      output_path = File.join(TEMP_DIR, dir, "#{prefix}calendar.json")
      args        = ['-i', input_path, '-o', output_path]
      league      = league_serializer.deserialize(File.read(input_path))

      described_class.new(args:, io:).invoke!

      calendar = calendar_serializer.deserialize(File.read(output_path))

      league.teams.each do |team|
        expect(calendar.season_games_for(team:).length).to eq(82)
      end
    end
  end

  describe 'querying the calendar' do
    context 'when no team or date specified' do
      specify 'last line includes correct game count' do
        args = ['-c', calendar_path]

        described_class.new(args:, io:).invoke!

        lines = io.string.split("\n")
        season_game_count = (82 * 30) / 2 # divide by 2 because each matchup (line) consists of two teams

        expect(lines.last).to include("##{season_game_count}")
      end
    end

    context 'when team is specified' do
      specify 'last line includes correct game count' do
        team = 'C0-D0-T0'
        args = ['-c', calendar_path, '-t', team]

        described_class.new(args:, io:).invoke!

        lines = io.string.split("\n")
        season_game_count = 82

        expect(lines.last).to include("##{season_game_count}")
      end

      specify 'all lines include the exact team id' do
        team = 'C0-D0-T0'
        args = ['-c', calendar_path, '-t', team]

        described_class.new(args:, io:).invoke!

        lines = io.string.split("\n")

        expect(lines).to all(include(team))
      end
    end

    context 'when date is specified' do
      specify 'last line includes correct game count' do
        args = ['-c', calendar_path, '-d', '2005-11-29']

        described_class.new(args:, io:).invoke!

        lines = io.string.split("\n")
        season_game_count = 8 # we know there are 8 games on this date from the JSON calendar file

        expect(lines.last).to include("##{season_game_count}")
      end

      specify 'all lines include the exact date' do
        date = '2005-11-29'
        args = ['-c', calendar_path, '-d', date]

        described_class.new(args:, io:).invoke!

        lines = io.string.split("\n")

        expect(lines).to all(include(date))
      end
    end
  end
end
