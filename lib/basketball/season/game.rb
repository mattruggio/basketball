# frozen_string_literal: true

module Basketball
  module Season
    # Base class describing what all games have in common.
    class Game
      attr_reader :date, :home_opponent, :away_opponent

      def initialize(date:, home_opponent:, away_opponent:)
        super()

        raise ArgumentError, 'date is required'             unless date
        raise ArgumentError, 'home_opponent is required'    unless home_opponent
        raise ArgumentError, 'away_opponent is required'    unless away_opponent
        raise ArgumentError, 'teams cannot play themselves' if home_opponent == away_opponent

        @date          = date
        @home_opponent = home_opponent
        @away_opponent = away_opponent

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

      def ==(other)
        self.class.name == other.class.name &&
          date == other.date &&
          home_opponent == other.home_opponent &&
          away_opponent == other.away_opponent
      end
      alias eql? ==

      def hash
        [self.class.name, date, home_opponent, away_opponent].hash
      end
    end
  end
end
