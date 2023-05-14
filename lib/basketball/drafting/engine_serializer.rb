# frozen_string_literal: true

require_relative 'front_office'
require_relative 'player'
require_relative 'pick_event'
require_relative 'sim_event'
require_relative 'skip_event'

module Basketball
  module Drafting
    class EngineSerializer
      EVENT_CLASSES = {
        'PickEvent' => PickEvent,
        'SimEvent' => SimEvent,
        'SkipEvent' => SkipEvent
      }.freeze

      private_constant :EVENT_CLASSES

      def to_hash(engine)
        {
          'info' => serialize_info(engine),
          'engine' => serialize_engine(engine),
          'league' => serialize_league(engine)
        }
      end

      def from_hash(json)
        front_offices = deserialize_front_offices(json)
        players       = deserialize_players(json)
        events        = deserialize_events(json, players, front_offices)

        engine_opts = {
          players:,
          front_offices:,
          events:
        }

        engine_opts[:rounds] = json.dig('engine', 'rounds') if json.dig('engine', 'rounds')

        Engine.new(**engine_opts)
      end

      def deserialize(string)
        json = JSON.parse(string)

        from_hash(json)
      end

      def serialize(engine)
        to_hash(engine).to_json
      end

      private

      def serialize_engine(engine)
        {
          'rounds' => engine.rounds,
          'front_offices' => serialize_front_offices(engine),
          'players' => serialize_players(engine),
          'events' => serialize_events(engine.events)
        }
      end

      def serialize_info(engine)
        {
          'total_picks' => engine.total_picks,
          'current_round' => engine.current_round,
          'current_round_pick' => engine.current_round_pick,
          'current_front_office' => engine.current_front_office&.id,
          'current_pick' => engine.current_pick,
          'remaining_picks' => engine.remaining_picks,
          'done' => engine.done?
        }
      end

      def serialize_league(engine)
        league = engine.to_league

        rosters = league.rosters.to_h do |roster|
          [
            roster.id,
            {
              'players' => roster.players.map(&:id)
            }
          ]
        end

        {
          'free_agents' => league.free_agents.map(&:id),
          'rosters' => rosters
        }
      end

      def serialize_front_offices(engine)
        engine.front_offices.to_h do |front_office|
          [
            front_office.id,
            {
              'name' => front_office.name,
              'fuzz' => front_office.fuzz,
              'depth' => front_office.depth,
              'prioritized_positions' => front_office.prioritized_positions.map(&:code)
            }
          ]
        end
      end

      def serialize_players(engine)
        engine.players.to_h do |player|
          [
            player.id,
            {
              'first_name' => player.first_name,
              'last_name' => player.last_name,
              'overall' => player.overall,
              'position' => player.position.code
            }
          ]
        end
      end

      def serialize_events(events)
        events.map do |event|
          {
            'type' => event.class.name.split('::').last,
            'front_office' => event.front_office.id,
            'pick' => event.pick,
            'round' => event.round,
            'round_pick' => event.round_pick
          }.tap do |hash|
            hash['player'] = event.player.id if event.respond_to?(:player)
          end
        end
      end

      def deserialize_front_offices(json)
        (json.dig('engine', 'front_offices') || []).map do |id, front_office_hash|
          prioritized_positions = (front_office_hash['prioritized_positions'] || []).map do |v|
            Position.new(v)
          end

          front_office_opts = {
            id:,
            name: front_office_hash['name'],
            prioritized_positions:,
            fuzz: front_office_hash['fuzz'],
            depth: front_office_hash['depth']
          }

          FrontOffice.new(**front_office_opts)
        end
      end

      def deserialize_players(json)
        (json.dig('engine', 'players') || []).map do |id, player_hash|
          player_opts = {
            id:,
            first_name: player_hash['first_name'],
            last_name: player_hash['last_name'],
            overall: player_hash['overall'],
            position: Position.new(player_hash['position'])
          }

          Player.new(**player_opts)
        end
      end

      def deserialize_events(json, players, front_offices)
        (json.dig('engine', 'events') || []).map do |event_hash|
          event_opts = event_hash.slice('pick', 'round', 'round_pick').merge(
            front_office: front_offices.find { |t| t.id == event_hash['front_office'] }
          )

          class_constant = EVENT_CLASSES.fetch(event_hash['type'])

          if [PickEvent, SimEvent].include?(class_constant)
            event_opts[:player] = players.find { |p| p.id == event_hash['player'] }
          end

          class_constant.new(**event_opts)
        end
      end
    end
  end
end
