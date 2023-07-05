# frozen_string_literal: true

module Basketball
  module Season
    # Base class describing what all games have in common.
    class Game < ValueObject
      value_reader :date, :home_opponent, :away_opponent, :opponent_type

      def initialize(date:, home_opponent:, away_opponent:, opponent_type:)
        super()

        raise ArgumentError, 'date is required'             unless date
        raise ArgumentError, 'home_opponent is required'    unless home_opponent
        raise ArgumentError, 'away_opponent is required'    unless away_opponent
        raise ArgumentError, 'teams cannot play themselves' if home_opponent == away_opponent
        raise ArgumentError, 'opponent_type is required'    unless opponent_type

        @date          = date
        @home_opponent = home_opponent
        @away_opponent = away_opponent
        @opponent_type = OpponentType.parse(opponent_type)

        freeze
      end

      def for?(team)
        teams.include?(team)
      end

      def teams
        [home_opponent, away_opponent]
      end

      def to_s
        "#{date} - #{away_opponent} at #{home_opponent}"
      end
    end
  end
end
