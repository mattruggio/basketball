# frozen_string_literal: true

require_relative 'calendar_serializer'
require_relative 'conference'
require_relative 'coordinator'
require_relative 'division'
require_relative 'league'
require_relative 'league_serializer'
require_relative 'team'

module Basketball
  module Season
    # Examples:
    #   exe/basketball-season-scheduling -o tmp/league.json
    #   exe/basketball-season-scheduling -i tmp/league.json -o tmp/calendar.json
    #   exe/basketball-season-scheduling -i tmp/league.json -o tmp/calendar.json -y 2005
    #   exe/basketball-season-scheduling -c tmp/calendar.json
    #   exe/basketball-season-scheduling -c tmp/calendar.json -t C0-D0-T0
    #   exe/basketball-season-scheduling -c tmp/calendar.json -d 2005-02-03
    #   exe/basketball-season-scheduling -c tmp/calendar.json -d 2005-02-03 -t C0-D0-T0
    class SchedulingCLI
      attr_reader :opts,
                  :league_serializer,
                  :calendar_serializer,
                  :io,
                  :coordinator

      def initialize(args:, io: $stdout)
        @io                  = io
        @opts                = slop_parse(args)
        @league_serializer   = LeagueSerializer.new
        @calendar_serializer = CalendarSerializer.new
        @coordinator         = Coordinator.new

        freeze
      end

      def invoke!
        if output?
          out_dir = File.dirname(output)
          FileUtils.mkdir_p(out_dir)
        end

        if output? && no_input?
          execute_with_no_input
        elsif output?
          execute_with_input
        end

        output_cal_query if cal

        self
      end

      private

      def output_cal_query
        contents      = File.read(cal)
        calendar      = calendar_serializer.deserialize(contents)
        team_instance = team ? calendar.team(team) : nil
        games         = calendar.games_for(date:, team: team_instance).sort_by(&:date)
        pre_counter   = 1
        counter       = 1

        io.puts("Games for [team: #{team}, date: #{date}]")
        games.each do |game|
          if game.is_a?(PreseasonGame)
            io.puts("##{pre_counter} - #{game}")
            pre_counter += 1
          else
            io.puts("##{counter} - #{game}")
            counter += 1
          end
        end
      end

      def execute_with_input
        io.puts("Loading league from: #{input}")

        contents = File.read(input)
        league   = league_serializer.deserialize(contents)

        io.puts("Generating calendar for the year #{year}...")

        calendar = coordinator.schedule(league:, year:)
        contents = calendar_serializer.serialize(calendar)

        File.write(output, contents)

        io.puts("Calendar written to: #{output}")
      end

      def execute_with_no_input
        league   = generate_league
        contents = league_serializer.serialize(league)

        File.write(output, contents)

        io.puts("League written to: #{output}")
      end

      def cal
        opts[:cal].to_s.empty? ? nil : opts[:cal]
      end

      def team
        opts[:team].to_s.empty? ? nil : opts[:team]
      end

      def date
        opts[:date].to_s.empty? ? nil : Date.parse(opts[:date])
      end

      def year
        opts[:year].to_s.empty? ? Date.today.year : opts[:year]
      end

      def no_input?
        input.to_s.empty?
      end

      def input
        opts[:input]
      end

      def output?
        !output.to_s.empty?
      end

      def output
        opts[:output]
      end

      def generate_conferences
        2.times.map do |i|
          id = "C#{i}"

          Conference.new(
            id:,
            name: Faker::Esport.league,
            divisions: generate_divisions("#{id}-")
          )
        end
      end

      def generate_divisions(id_prefix)
        3.times.map do |j|
          id = "#{id_prefix}D#{j}"

          Division.new(
            id:,
            name: Faker::Address.community,
            teams: generate_teams("#{id}-")
          )
        end
      end

      def generate_teams(id_prefix)
        5.times.map do |k|
          Team.new(
            id: "#{id_prefix}T#{k}",
            name: Faker::Team.name
          )
        end
      end

      def generate_league
        League.new(conferences: generate_conferences)
      end

      def slop_parse(args)
        Slop.parse(args) do |o|
          o.banner = 'Usage: basketball-schedule [options] ...'

          output_description = <<~DESC
            If input path is omitted then a new league will be written to this path.
            If an input path is specified then a Calendar will be written to the output path.
          DESC

          # League and Calendar Generation Interface
          o.string  '-i', '--input',  'Path to load the League from. If omitted then a new league will be generated.'
          o.string  '-o', '--output', output_description
          o.integer '-y', '--year',   'Year to use to generate a calendar for (defaults to current year).'

          # Calendar Query Interface
          o.string  '-c', '--cal',  'Path to load a Calendar from. If omitted then no matchups will be outputted.'
          o.string  '-d', '--date', 'Filter matchups to just the date specified (requires --cal option).'
          o.string  '-t', '--team', 'Filter matchups to just the team ID specified (requires --cal option).'

          o.on '-h', '--help', 'Print out help, like this is doing right now.' do
            io.puts(o)
            exit
          end
        end.to_h
      end
    end
  end
end
