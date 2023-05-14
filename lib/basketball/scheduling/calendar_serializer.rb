# frozen_string_literal: true

require_relative 'game'
require_relative 'preseason_game'
require_relative 'season_game'

module Basketball
  module Scheduling
    class CalendarSerializer
      GAME_CLASSES = {
        'PreseasonGame' => PreseasonGame,
        'SeasonGame' => SeasonGame
      }.freeze

      def to_hash(calendar)
        teams = calendar.games.flat_map(&:teams).uniq

        {
          'year' => calendar.preseason_start_date.year,
          'teams' => serialize_teams(teams),
          'games' => serialize_games(calendar.games)
        }
      end

      def from_hash(json)
        Calendar.new(
          year: json['year'].to_i,
          games: deserialize_games(json)
        )
      end

      def deserialize(string)
        json = JSON.parse(string)

        from_hash(json)
      end

      def serialize(calendar)
        to_hash(calendar).to_json
      end

      private

      ## Deserialization

      def deserialize_games(json)
        teams = deserialize_teams(json['teams'])

        (json['games'] || []).map do |game_hash|
          GAME_CLASSES.fetch(game_hash['type']).new(
            date: Date.parse(game_hash['date']),
            home_team: teams.fetch(game_hash['home_team']),
            away_team: teams.fetch(game_hash['away_team'])
          )
        end
      end

      def deserialize_teams(teams)
        (teams || []).to_h do |id, team_hash|
          team = Team.new(id:, name: team_hash['name'])

          [
            team.id,
            team
          ]
        end
      end

      ## Serialization

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

      def serialize_games(games)
        games.sort_by(&:date).map do |game|
          {
            'type' => game.class.name.split('::').last,
            'date' => game.date.to_s,
            'home_team' => game.home_team.id,
            'away_team' => game.away_team.id
          }
        end
      end
    end
  end
end
