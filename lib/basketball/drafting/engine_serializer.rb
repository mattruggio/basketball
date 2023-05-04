# frozen_string_literal: true

module Basketball
  module Drafting
    class EngineSerializer
      EVENT_CLASSES = {
        'PickEvent' => PickEvent,
        'SimEvent' => SimEvent
      }.freeze

      private_constant :EVENT_CLASSES

      def deserialize(string)
        json        = JSON.parse(string, symbolize_names: true)
        teams       = deserialize_teams(json)
        players     = deserialize_players(json)
        events = deserialize_events(json, players, teams)

        engine_opts = {
          players:,
          teams:,
          events:
        }

        engine_opts[:rounds] = json.dig(:engine, :rounds) if json.dig(:engine, :rounds)

        Engine.new(**engine_opts)
      end

      def serialize(engine)
        {
          info: serialize_info(engine),
          engine: serialize_engine(engine),
          rosters: serialize_rosters(engine)
        }.to_json
      end

      private

      def serialize_engine(engine)
        {
          rounds: engine.rounds,
          teams: serialize_teams(engine),
          players: serialize_players(engine),
          events: serialize_events(engine.events)
        }
      end

      def serialize_info(engine)
        {
          total_picks: engine.total_picks,
          current_round: engine.current_round,
          current_round_pick: engine.current_round_pick,
          current_team: engine.current_team&.id,
          current_pick: engine.current_pick,
          remaining_picks: engine.remaining_picks,
          done: engine.done?,
          undrafted_players: engine.undrafted_players.map(&:id)
        }
      end

      def serialize_rosters(engine)
        engine.rosters.to_h do |roster|
          [
            roster.id,
            {
              events: roster.events.map(&:id),
              players: roster.events.map { |event| event.player.id }
            }
          ]
        end
      end

      def serialize_teams(engine)
        engine.teams.to_h do |team|
          [
            team.id,
            {
              name: team.name,
              front_office: {
                fuzz: team.front_office.fuzz,
                depth: team.front_office.depth,
                prioritized_positions: team.front_office.prioritized_positions
              }
            }
          ]
        end
      end

      def serialize_players(engine)
        engine.players.to_h do |player|
          [
            player.id,
            {
              first_name: player.first_name,
              last_name: player.last_name,
              overall: player.overall,
              position: player.position.value
            }
          ]
        end
      end

      def serialize_events(events)
        events.map do |event|
          {
            type: event.class.name.split('::').last,
            id: event.id,
            player: event.player.id,
            team: event.team.id,
            pick: event.pick,
            round: event.round,
            round_pick: event.round_pick
          }
        end
      end

      def deserialize_teams(json)
        (json.dig(:engine, :teams) || []).map do |id, team_hash|
          team_opts = {
            id:,
            name: team_hash[:name]
          }

          if team_hash.key?(:front_office)
            front_office_hash = team_hash[:front_office] || {}

            prioritized_positions = (front_office_hash[:prioritized_positions] || []).map do |v|
              Position.new(v)
            end

            front_office_opts = {
              prioritized_positions:,
              fuzz: front_office_hash[:fuzz],
              depth: front_office_hash[:depth]
            }

            team_opts[:front_office] = FrontOffice.new(**front_office_opts)
          end

          Team.new(**team_opts)
        end
      end

      def deserialize_players(json)
        (json.dig(:engine, :players) || []).map do |id, player_hash|
          player_opts = player_hash.merge(
            id:,
            position: Position.new(player_hash[:position])
          )

          Player.new(**player_opts)
        end
      end

      def deserialize_events(json, players, teams)
        (json.dig(:engine, :events) || []).map do |event_hash|
          event_opts = event_hash.slice(:id, :pick, :round, :round_pick).merge(
            player: players.find { |p| p.id == event_hash[:player] },
            team: teams.find { |t| t.id == event_hash[:team] }
          )

          class_constant = EVENT_CLASSES.fetch(event_hash[:type])

          class_constant.new(**event_opts)
        end
      end
    end
  end
end
