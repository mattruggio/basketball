# frozen_string_literal: true

require_relative 'front_office'
require_relative 'player'
require_relative 'pick_event'
require_relative 'sim_event'
require_relative 'skip_event'

module Basketball
  module Draft
    class RoomSerializer
      EVENT_CLASSES = {
        'PickEvent' => PickEvent,
        'SimEvent' => SimEvent,
        'SkipEvent' => SkipEvent
      }.freeze

      private_constant :EVENT_CLASSES

      def to_hash(room)
        {
          'info' => serialize_info(room),
          'room' => serialize_room(room),
          'league' => serialize_league(room)
        }
      end

      def from_hash(json)
        front_offices = deserialize_front_offices(json)
        players       = deserialize_players(json)
        events        = deserialize_events(json, players, front_offices)

        room_opts = {
          players:,
          front_offices:,
          events:
        }

        room_opts[:rounds] = json.dig('room', 'rounds') if json.dig('room', 'rounds')

        Room.new(**room_opts)
      end

      def deserialize(string)
        json = JSON.parse(string)

        from_hash(json)
      end

      def serialize(room)
        to_hash(room).to_json
      end

      private

      def serialize_room(room)
        {
          'rounds' => room.rounds,
          'front_offices' => serialize_front_offices(room),
          'players' => serialize_players(room),
          'events' => serialize_events(room.events)
        }
      end

      def serialize_info(room)
        {
          'total_picks' => room.total_picks,
          'current_round' => room.current_round,
          'current_round_pick' => room.current_round_pick,
          'current_front_office' => room.current_front_office&.id,
          'current_pick' => room.current_pick,
          'remaining_picks' => room.remaining_picks,
          'done' => room.done?
        }
      end

      def serialize_league(room)
        league = room.to_league

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

      def serialize_front_offices(room)
        room.front_offices.to_h do |front_office|
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

      def serialize_players(room)
        room.players.to_h do |player|
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
        (json.dig('room', 'front_offices') || []).map do |id, front_office_hash|
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
        (json.dig('room', 'players') || []).map do |id, player_hash|
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
        (json.dig('room', 'events') || []).map do |event_hash|
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
