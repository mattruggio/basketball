# frozen_string_literal: true

module Basketball
  module App
    # Examples:
    #   exe/basketball-coordinator -o tmp/coordinator.json
    #   exe/basketball-coordinator -i tmp/coordinator.json -o tmp/coordinator2.json -d 1
    #   exe/basketball-coordinator -i tmp/coordinator2.json -e
    #   exe/basketball-coordinator -i tmp/coordinator2.json -o tmp/coordinator2.json -d 2
    #   exe/basketball-coordinator -i tmp/coordinator2.json -a
    #
    #   exe/basketball-coordinator -o tmp/coordinator.json -ae
    class CoordinatorCLI
      attr_reader :opts, :io, :coordinator_repository

      def initialize(
        args:,
        io: $stdout,
        coordinator_repository: CoordinatorRepository.new(FileStore.new)
      )
        raise ArgumentError, 'coordinator_repository is required' unless coordinator_repository
        raise ArgumentError, 'io is required'                     unless io

        @io                     = io
        @opts                   = slop_parse(args)
        @coordinator_repository = coordinator_repository

        if no_input? && no_output?
          io.puts('Input and/or output paths are required.')

          exit
        end

        freeze
      end

      def invoke!
        coordinator = read

        execute(coordinator)
        output_status(coordinator)
        write(coordinator)
        events(coordinator)

        self
      end

      private

      def output_status(coordinator)
        io.puts
        io.puts('Status')

        if coordinator.done?
          io.puts('Coordinator is complete!')
        else
          io.puts("#{coordinator.days_left} Remaining day(s) (#{coordinator.total_days} total)")
          io.puts("Currently on: #{coordinator.current_date}")
          io.puts("#{coordinator.exhibitions_left} Remaining preseason (#{coordinator.total_exhibitions} total)")
          io.puts("#{coordinator.regulars_left} Remaining season (#{coordinator.total_regulars} total)")
        end
      end

      def execute(coordinator)
        event_count = 0

        io.puts
        io.puts('New Events')

        days&.times do
          coordinator.sim! do |event|
            io.puts(event)

            event_count += 1
          end
        end

        if sim_all
          coordinator.sim_rest! do |event|
            io.puts(event)

            event_count += 1
          end
        end

        io.puts("Generated #{event_count} new event(s)")

        nil
      end

      def days
        opts[:days]
      end

      def sim_all
        opts[:sim_all]
      end

      def write(coordinator)
        path = output? ? output : input

        coordinator_repository.save(path, coordinator)

        path
      end

      def make_league(team_count: 2, players_per_team_count: 4)
        Org::League.new.tap do |league|
          team_count.times do |i|
            team = Org::Team.new(id: "T-#{i}")

            players_per_team_count.times do |j|
              player = Org::Player.new(
                id: "T-#{i}-P-#{j}",
                overall: rand(20..100),
                position: Org::Position.random
              )

              team.sign!(player)
            end

            league.register!(team)
          end
        end
      end

      def make_calendar(league:)
        preseason_start_date = Date.new(2000, 1, 1)
        season_start_date = Date.new(2000, 1, 11)

        exhibitions = make_games(
          start_date: preseason_start_date,
          count: 10,
          league:,
          game_class: Season::Exhibition
        )

        regulars = make_games(
          start_date: season_start_date,
          count: 10,
          league:,
          game_class: Season::Regular
        )

        Season::Calendar.new(
          preseason_start_date:,
          preseason_end_date: Date.new(2000, 1, 10),
          season_start_date:,
          season_end_date: Date.new(2000, 1, 20),
          games: exhibitions + regulars
        )
      end

      def make_games(start_date:, count:, league:, game_class:)
        count.times.map do |i|
          home_team, away_team = league.teams.sample(2)

          game_class.new(
            date: start_date + i,
            home_opponent: Season::Opponent.new(id: home_team.id),
            away_opponent: Season::Opponent.new(id: away_team.id)
          )
        end
      end

      def make_coordinator
        league       = make_league
        current_date = Date.new(2000, 1, 1)
        calendar     = make_calendar(league:)

        Season::Coordinator.new(
          calendar:,
          current_date:,
          league:
        )
      end

      def read
        coordinator =
          if input?
            io.puts("Coordinator loaded from: #{input}")

            coordinator_repository.load(input)
          else
            io.puts('Input path was not provided, generating fresh coordinator')

            make_coordinator
          end

        io.puts("Current Date: #{coordinator.current_date}")

        coordinator
      end

      def input
        opts[:input]
      end

      def input?
        !no_input?
      end

      def no_input?
        input.to_s.empty?
      end

      def output
        opts[:output]
      end

      def no_output?
        output.to_s.empty?
      end

      def output?
        !no_output?
      end

      def events(coordinator)
        return unless opts[:events]

        io.puts
        io.puts('Event Log')

        puts coordinator.results
      end

      def slop_parse(args)
        Slop.parse(args) do |o|
          o.banner = 'Usage: basketball-coordinator [options] ...'

          input_description = <<~DESC
            Path to load the Coordinator from. If omitted then a new coordinator will be created.
          DESC

          o.string  '-i', '--input', input_description.chomp
          o.string  '-o', '--output',  'Path to save updated coordinator. If omitted then the input path will be used.'
          o.integer '-d', '--days',    'Number of days to simulate'
          o.bool    '-a', '--sim-all', 'Simulate the rest of the coordinator', default: false
          o.bool    '-e', '--events',  'Output event log.', default: false

          o.on '-h', '--help', 'Print out help, like this is doing right now.' do
            io.puts(o)
            exit
          end
        end.to_h
      end
    end
  end
end
