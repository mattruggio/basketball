# frozen_string_literal: true

module Basketball
  module App
    # Provides methods to serialize/deserialize a League object
    module LeagueSerializable
      # Serialization

      def serialize_league(league)
        {
          teams: league.teams.map { |team| serialize_team(team) }
        }
      end

      def serialize_team(team)
        {
          id: team.id,
          players: team.players.map { |player| serialize_player(player) }
        }
      end

      def serialize_player(player)
        {
          id: player.id,
          overall: player.overall,
          position: player.position&.code
        }
      end

      # Deserialization

      def deserialize_league(league_hash)
        team_hashes = league_hash[:teams] || []
        teams       = team_hashes.map { |team_hash| deserialize_team(team_hash) }

        Org::League.new(teams:)
      end

      def deserialize_team(team_hash)
        players = (team_hash[:players] || []).map { |player_hash| deserialize_player(player_hash) }

        Org::Team.new(id: team_hash[:id], players:)
      end

      def deserialize_player(player_hash)
        Org::Player.new(
          id: player_hash[:id],
          overall: player_hash[:overall],
          position: Org::Position.new(player_hash[:position])
        )
      end
    end
  end
end
