# frozen_string_literal: true

module Basketball
  module Season
    class LeagueSerializer
      def to_hash(league)
        {
          'conferences' => serialize_conferences(league.conferences)
        }
      end

      def from_hash(json)
        conferences = deserialize_conferences(json['conferences'])

        League.new(conferences:)
      end

      def deserialize(string)
        json = JSON.parse(string)

        from_hash(json)
      end

      def serialize(league)
        to_hash(league).to_json
      end

      private

      ## Deserialization

      def deserialize_conferences(conferences)
        (conferences || []).map do |conference_id, conference_hash|
          Conference.new(
            id: conference_id,
            name: conference_hash['name'],
            divisions: deserialize_divisions(conference_hash['divisions'])
          )
        end
      end

      def deserialize_divisions(divisions)
        (divisions || []).map do |division_id, division_hash|
          Division.new(
            id: division_id,
            name: division_hash['name'],
            teams: deserialize_teams(division_hash['teams'])
          )
        end
      end

      def deserialize_teams(teams)
        (teams || []).map do |team_id, team_hash|
          Team.new(
            id: team_id,
            name: team_hash['name']
          )
        end
      end

      ## Serialization

      def serialize_conferences(conferences)
        conferences.to_h do |conference|
          [
            conference.id,
            {
              'name' => conference.name,
              'divisions' => serialize_divisions(conference.divisions)
            }
          ]
        end
      end

      def serialize_divisions(divisions)
        divisions.to_h do |division|
          [
            division.id,
            {
              'name' => division.name,
              'teams' => serialize_teams(division.teams)
            }
          ]
        end
      end

      def serialize_teams(teams)
        teams.to_h do |team|
          [
            team.id,
            {
              'name' => team.name
            }
          ]
        end
      end
    end
  end
end
