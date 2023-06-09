# frozen_string_literal: true

module Basketball
  module App
    # Can load and save Room objects to JSON files.
    class RoomRepository < DocumentRepository
      PICK_EVENT = 'Pick'
      SKIP_EVENT = 'Skip'

      private_constant :PICK_EVENT, :SKIP_EVENT

      private

      def from_h(hash)
        front_offices = deserialize_front_offices(hash[:front_offices])
        players       = deserialize_players(hash[:players])
        events        = deserialize_events(hash[:events], players:, front_offices:)

        Draft::Room.new(
          rounds: hash[:rounds],
          front_offices:,
          players:,
          events:
        )
      end

      def to_h(room)
        {
          rounds: room.rounds,
          front_offices: room.front_offices.map { |fo| serialize_front_office(fo) },
          players: room.players.map { |p| serialize_player(p) },
          events: serialize_events(room.events)
        }
      end

      # Serialization

      def serialize_player(player)
        {
          id: player.id,
          overall: player.overall,
          position: player.position&.code
        }
      end

      def serialize_front_office(front_office)
        {
          id: front_office.id,
          risk_level: front_office.risk_level,
          prioritized_positions: front_office.prioritized_positions.map(&:code),
          star_level: front_office.star_level
        }
      end

      def serialize_events(events)
        events.map do |event|
          case event
          when Draft::Pick
            serialize_pick(event)
          when Draft::Skip
            serialize_skip(event)
          end
        end
      end

      def serialize_pick(event)
        {
          type: PICK_EVENT,
          front_office: event.front_office.id,
          pick: event.pick,
          round: event.round,
          round_pick: event.round_pick,
          auto: event.auto,
          player: event.player.id
        }
      end

      def serialize_skip(event)
        {
          type: SKIP_EVENT,
          front_office: event.front_office.id,
          pick: event.pick,
          round: event.round,
          round_pick: event.round_pick
        }
      end

      # Deserialization

      def deserialize_player(player_hash)
        Org::Player.new(
          id: player_hash[:id],
          overall: player_hash[:overall],
          position: Org::Position.new(player_hash[:position])
        )
      end

      def deserialize_front_office(hash)
        Draft::FrontOffice.new(
          id: hash[:id],
          risk_level: hash[:risk_level].to_i,
          prioritized_positions: (hash[:prioritized_positions] || []).map { |c| Org::Position.new(c) },
          star_level: hash[:star_level].to_i
        )
      end

      def deserialize_front_offices(hashes)
        (hashes || []).map { |fo| deserialize_front_office(fo) }
      end

      def deserialize_players(hashes)
        (hashes || []).map { |hash| deserialize_player(hash) }
      end

      def deserialize_pick(hash, players:, front_office:)
        player_id = hash[:player]
        player    = players.find { |p| p.id == player_id }

        Draft::Pick.new(
          front_office:,
          pick: hash[:pick],
          round: hash[:round],
          round_pick: hash[:round_pick],
          player:,
          auto: hash[:auto]
        )
      end

      def deserialize_skip(hash, front_office:)
        Draft::Skip.new(
          front_office:,
          pick: hash[:pick],
          round: hash[:round],
          round_pick: hash[:round_pick]
        )
      end

      def deserialize_events(hashes, players:, front_offices:)
        (hashes || []).map do |hash|
          front_office_id = hash[:front_office]
          front_office    = front_offices.find { |fo| fo.id == front_office_id }

          case hash[:type]
          when PICK_EVENT
            deserialize_pick(hash, players:, front_office:)
          when SKIP_EVENT
            deserialize_skip(hash, front_office:)
          end
        end
      end
    end
  end
end
