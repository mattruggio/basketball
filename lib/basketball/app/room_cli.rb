# frozen_string_literal: true

module Basketball
  module App
    # Examples:
    #   exe/basketball-draft-room -o tmp/draft.json
    #   exe/basketball-draft-room -i tmp/draft.json -o tmp/draft-wip.json -s 26 -p P-5,P-10 -l 10
    #   exe/basketball-draft-room -i tmp/draft-wip.json -x 2
    #   exe/basketball-draft-room -i tmp/draft-wip.json -g -l 10
    #   exe/basketball-draft-room -i tmp/draft-wip.json -s 30 -l 10
    #   exe/basketball-draft-room -i tmp/draft-wip.json -ate
    class RoomCLI
      class PlayerNotFound < StandardError; end

      attr_reader :opts,
                  :io,
                  :room_repository

      def initialize(
        args:,
        io: $stdout,
        room_repository: RoomRepository.new(FileStore.new)
      )
        @io                = io
        @opts              = slop_parse(args)
        @room_repository   = room_repository

        if opts[:input].to_s.empty? && opts[:output].to_s.empty?
          io.puts('Input and/or output paths are required.')

          exit
        end

        freeze
      end

      def invoke!
        room = load_room

        execute(room)
        status(room)
        write(room)
        events(room)
        teams(room)
        query(room)

        self
      end

      private

      def status(room)
        io.puts
        io.puts('Status')

        if room.done?
          io.puts('Draft is complete!')
        else
          round        = room.round
          round_pick   = room.round_pick
          front_office = room.front_office

          io.puts("#{room.remaining_picks} Remaining pick(s)")
          io.puts("Up Next: Round #{round} pick #{round_pick} for #{front_office}")
        end
      end

      def slop_parse(args)
        Slop.parse(args) do |o|
          o.banner = 'Usage: basketball-draft-room [options] ...'

          o.string  '-i', '--input',        'Path to load the Room from. If omitted then a new draft will be generated.'
          o.string  '-o', '--output',       'Path to write the room to (if omitted then input path will be used)'
          o.integer '-s', '--simulate',     'Number of picks to simulate (default is 0).', default: 0
          o.bool    '-a', '--simulate-all', 'Simulate the rest of the draft', default: false
          o.array   '-p', '--picks',        'Comma-separated list of ordered player IDs to pick.', delimiter: ','
          o.integer '-l', '--list',         'List the top rated available players (default is 0).', default: 0
          o.bool    '-t', '--teams',        'Output all teams and their picks', default: false
          o.integer '-x', '--skip',         'Number of picks to skip (default is 0).', default: 0
          o.bool    '-e', '--events',       'Output event log.', default: false

          o.on '-h', '--help', 'Print out help, like this is doing right now.' do
            io.puts(o)
            exit
          end
        end.to_h
      end

      def load_room
        if opts[:input].to_s.empty?
          io.puts('Input path was not provided, generating fresh front_offices and players')

          generate_draft
        else
          io.puts("Draft loaded from: #{opts[:input]}")

          read
        end
      end

      def generate_draft
        front_offices = 30.times.map do |i|
          Draft::FrontOffice.new(
            id: "T-#{i + 1}"
          )
        end

        players = 450.times.map do |i|
          Org::Player.new(
            id: "P-#{i + 1}",
            overall: (20..100).to_a.sample,
            position: Org::Position.random
          )
        end

        Draft::Room.new(rounds: 12, players:, front_offices:)
      end

      def teams(room)
        return unless opts[:teams]

        io.puts
        io.puts(room.teams)
      end

      def events(room)
        return unless opts[:events]

        io.puts
        io.puts('Event Log')

        puts room.events
      end

      def query(room)
        list = opts[:list]

        return if list <= 0

        players = room.undrafted_players.sort_by(&:overall).reverse.take(opts[:list])

        io.puts
        io.puts("Top #{list} available players")
        io.puts(players)
      end

      def read
        room_repository.load(opts[:input])
      end

      # rubocop:disable Metrics/AbcSize
      def execute(room)
        event_count = 0

        io.puts
        io.puts('New Events')

        (opts[:picks] || []).each do |id|
          break if room.done?

          player = room.players.find { |p| p.id == id.to_s.upcase }

          raise PlayerNotFound, "player not found by id: #{id}" unless player

          event = room.pick!(player)

          io.puts(event)

          event_count += 1
        end

        opts[:skip].times do
          event = room.skip!

          io.puts(event)

          event_count += 1
        end

        opts[:simulate].times do
          room.sim!

          event_count += 1
        end

        if opts[:simulate_all]
          room.sim_rest! do |event|
            io.puts(event)

            event_count += 1
          end
        end

        io.puts("Generated #{event_count} new event(s)")

        nil
      end
      # rubocop:enable Metrics/AbcSize

      def output_default_to_input
        opts[:output].to_s.empty? ? opts[:input] : opts[:output]
      end

      def write(room)
        output = output_default_to_input

        room_repository.save(output, room)

        io.puts
        io.puts("Draft written to: #{output}")

        nil
      end
    end
  end
end
