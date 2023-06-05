# frozen_string_literal: true

module Basketball
  module App
    # Provides methods to serialize/deserialize a League object
    module LeagueSerializable
      # Serialization

      def serialize_league(league)
        {
          id: league.id,
          conferences: serialize_conferences(league.conferences)
        }
      end

      def serialize_team(team)
        {
          id: team.id,
          players: team.players.map { |player| serialize_player(player) }
        }
      end

      def serialize_conferences(conferences)
        conferences.map do |conference|
          {
            id: conference.id,
            divisions: serialize_divisions(conference.divisions)
          }
        end
      end

      def serialize_divisions(divisions)
        divisions.map do |division|
          {
            id: division.id,
            teams: serialize_teams(division.teams)
          }
        end
      end

      def serialize_teams(teams)
        teams.map do |team|
          {
            id: team.id,
            players: serialize_players(team.players)
          }
        end
      end

      def serialize_players(players)
        players.map do |player|
          {
            id: player.id,
            overall: player.overall,
            position: player.position&.code
          }
        end
      end

      # Deserialization

      def deserialize_league(league_hash)
        Org::League.new(
          conferences: deserialize_conferences(league_hash[:conferences])
        )
      end

      def deserialize_conferences(conference_hashes)
        (conference_hashes || []).map do |conference_hash|
          Org::Conference.new(
            id: conference_hash[:id],
            divisions: deserialize_divisions(conference_hash[:divisions])
          )
        end
      end

      def deserialize_divisions(division_hashes)
        (division_hashes || []).map do |division_hash|
          Org::Division.new(
            id: division_hash[:id],
            teams: deserialize_teams(division_hash[:teams])
          )
        end
      end

      def deserialize_teams(team_hashes)
        (team_hashes || []).map do |team_hash|
          Org::Team.new(
            id: team_hash[:id],
            players: deserialize_players(team_hash[:players])
          )
        end
      end

      def deserialize_players(player_hashes)
        (player_hashes || []).map do |player_hash|
          Org::Player.new(
            id: player_hash[:id],
            overall: player_hash[:overall],
            position: Org::Position.new(player_hash[:position])
          )
        end
      end
    end
  end
end
