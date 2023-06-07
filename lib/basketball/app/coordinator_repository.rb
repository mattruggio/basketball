# frozen_string_literal: true

module Basketball
  module App
    # Knows how to flatten a Coordinator instance and rehydrate one from JSON and/or a Ruby hash.
    class CoordinatorRepository < DocumentRepository
      include LeagueSerializable

      GAME_CLASSES = {
        'Exhibition' => Season::Exhibition,
        'Regular' => Season::Regular
      }.freeze

      private_constant :GAME_CLASSES

      private

      def from_h(hash)
        Season::Coordinator.new(
          calendar: deserialize_calendar(hash[:calendar]),
          current_date: Date.parse(hash[:current_date]),
          results: deserialize_results(hash[:results]),
          league: deserialize_league(hash[:league])
        )
      end

      def to_h(coordinator)
        {
          id: coordinator.id,
          calendar: serialize_calendar(coordinator.calendar),
          current_date: coordinator.current_date.to_s,
          results: serialize_results(coordinator.results),
          league: serialize_league(coordinator.league)
        }
      end

      # Serialization

      def serialize_games(games)
        games.map { |game| serialize_game(game) }
      end

      def serialize_calendar(calendar)
        {
          exhibition_start_date: calendar.exhibition_start_date.to_s,
          exhibition_end_date: calendar.exhibition_end_date.to_s,
          regular_start_date: calendar.regular_start_date.to_s,
          regular_end_date: calendar.regular_end_date.to_s,
          games: serialize_games(calendar.games)
        }
      end

      def serialize_game(game)
        {
          type: game.class.name.split('::').last,
          date: game.date.to_s,
          home_opponent: game.home_opponent.id,
          away_opponent: game.away_opponent.id
        }
      end

      def serialize_result(result)
        {
          game: serialize_game(result.game),
          home_score: result.home_score,
          away_score: result.away_score
        }
      end

      def serialize_results(results)
        results.map do |result|
          serialize_result(result)
        end
      end

      # Deserialization

      def deserialize_calendar(calendar_hash)
        Season::Calendar.new(
          exhibition_start_date: Date.parse(calendar_hash[:exhibition_start_date]),
          exhibition_end_date: Date.parse(calendar_hash[:exhibition_end_date]),
          regular_start_date: Date.parse(calendar_hash[:regular_start_date]),
          regular_end_date: Date.parse(calendar_hash[:regular_end_date]),
          games: deserialize_games(calendar_hash[:games])
        )
      end

      def deserialize_games(game_hashes)
        (game_hashes || []).map { |game_hash| deserialize_game(game_hash) }
      end

      def deserialize_game(game_hash)
        GAME_CLASSES.fetch(game_hash[:type]).new(
          date: Date.parse(game_hash[:date]),
          home_opponent: Season::Opponent.new(id: game_hash[:home_opponent]),
          away_opponent: Season::Opponent.new(id: game_hash[:away_opponent])
        )
      end

      def deserialize_results(result_hashes)
        (result_hashes || []).map do |result_hash|
          deserialize_result(result_hash)
        end
      end

      def deserialize_result(result_hash)
        Season::Result.new(
          game: deserialize_game(result_hash[:game]),
          home_score: result_hash[:home_score],
          away_score: result_hash[:away_score]
        )
      end
    end
  end
end
