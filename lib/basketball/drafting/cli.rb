# frozen_string_literal: true

require_relative 'engine'
require_relative 'engine_serializer'
require_relative 'player_search'
require_relative 'position'

module Basketball
  module Drafting
    # Example:
    #   exe/basketball-draft -o tmp/draft.json
    #   exe/basketball-draft -i tmp/draft.json -o tmp/draft-wip.json -s 26 -p P-5,P-10 -t 10 -q PG
    #   exe/basketball-draft -i tmp/draft-wip.json -x 2
    #   exe/basketball-draft -i tmp/draft-wip.json -r -t 10
    #   exe/basketball-draft -i tmp/draft-wip.json -t 10 -q SG
    #   exe/basketball-draft -i tmp/draft-wip.json -s 30 -t 10
    #   exe/basketball-draft -i tmp/draft-wip.json -a -r
    #   exe/basketball-draft -i tmp/draft-wip.json -l
    class CLI
      class PlayerNotFound < StandardError; end

      attr_reader :opts, :serializer, :io

      def initialize(args:, io: $stdout)
        @io         = io
        @serializer = EngineSerializer.new
        @opts       = slop_parse(args)

        if opts[:input].to_s.empty? && opts[:output].to_s.empty?
          io.puts('Input and/or output paths are required.')

          exit
        end

        freeze
      end

      def invoke!
        engine = load_engine

        execute(engine)

        io.puts
        io.puts('Status')

        if engine.done?
          io.puts('Draft is complete!')
        else
          current_round        = engine.current_round
          current_round_pick   = engine.current_round_pick
          current_front_office = engine.current_front_office

          io.puts("#{engine.remaining_picks} Remaining pick(s)")
          io.puts("Up Next: Round #{current_round} pick #{current_round_pick} for #{current_front_office}")
        end

        write(engine)

        log(engine)

        league(engine)

        query(engine)

        self
      end

      private

      def slop_parse(args)
        Slop.parse(args) do |o|
          o.banner = 'Usage: draft [options] ...'

          o.string  '-i', '--input',
                    'Path to load the engine from. If omitted then a new draft will be generated.'
          o.string  '-o', '--output',       'Path to write the engine to (if omitted then input path will be used)'
          o.integer '-s', '--simulate',     'Number of picks to simulate (default is 0).', default: 0
          o.bool    '-a', '--simulate-all', 'Simulate the rest of the draft', default: false
          o.array   '-p', '--picks',        'Comma-separated list of ordered player IDs to pick.', delimiter: ','
          o.integer '-t', '--top',          'Output the top rated available players (default is 0).', default: 0
          o.string  '-q', '--query',        "Filter TOP by position: #{Position::ALL_VALUES.join(', ')}."
          o.bool    '-r', '--rosters',      'Output all front_office rosters.', default: false
          o.integer '-x', '--skip',         'Number of picks to skip (default is 0).', default: 0
          o.bool    '-l', '--log',          'Output event log.', default: false

          o.on '-h', '--help', 'Print out help, like this is doing right now.' do
            io.puts(o)
            exit
          end
        end.to_h
      end

      def load_engine
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
          FrontOffice.new(
            id: "T-#{i + 1}", name: Faker::Team.name
          )
        end

        players = 450.times.map do |i|
          Player.new(
            id: "P-#{i + 1}",
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            position: Position.random,
            overall: (0..100).to_a.sample
          )
        end

        Engine.new(players:, front_offices:)
      end

      def league(engine)
        return unless opts[:rosters]

        io.puts
        io.puts(engine.to_league)
      end

      def log(engine)
        return unless opts[:log]

        io.puts
        io.puts('Event Log')

        puts engine.events
      end

      # rubocop:disable Metrics/AbcSize
      def query(engine)
        top = opts[:top]

        return if top <= 0

        search   = PlayerSearch.new(engine.undrafted_players)
        position = opts[:query].to_s.empty? ? nil : Position.new(opts[:query])
        players  = search.query(position:).take(opts[:top])

        io.puts
        io.print("Top #{top} available players")

        if position
          io.puts(" for #{position} position:")
        else
          io.puts(' for all positions:')
        end

        io.puts(players)
      end
      # rubocop:enable Metrics/AbcSize

      def read
        contents = File.read(opts[:input])
        serializer.deserialize(contents)
      end

      # rubocop:disable Metrics/AbcSize
      def execute(engine)
        event_count = 0

        io.puts
        io.puts('New Events')

        (opts[:picks] || []).each do |id|
          break if engine.done?

          player = engine.players.find { |p| p.id == id.to_s.upcase }

          raise PlayerNotFound, "player not found by id: #{id}" unless player

          event = engine.pick!(player)

          io.puts(event)

          event_count += 1
        end

        opts[:skip].times do
          event = engine.skip!

          io.puts(event)

          event_count += 1
        end

        engine.sim!(opts[:simulate]) do |event|
          io.puts(event)

          event_count += 1
        end

        if opts[:simulate_all]
          engine.sim! do |event|
            io.puts(event)

            event_count += 1
          end
        end

        io.puts("Generated #{event_count} new event(s)")

        nil
      end
      # rubocop:enable Metrics/AbcSize

      def write(engine)
        output = opts[:output].to_s.empty? ? opts[:input] : opts[:output]

        contents = serializer.serialize(engine)
        out_dir  = File.dirname(output)

        FileUtils.mkdir_p(out_dir)

        File.write(output, contents)

        io.puts
        io.puts("Draft written to: #{output}")

        nil
      end
    end
  end
end
