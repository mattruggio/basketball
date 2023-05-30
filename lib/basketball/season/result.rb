# frozen_string_literal: true

module Basketball
  module Season
    # Base class describing the end result of a game.  This should/could be sub-classed to include
    # more sport-specific information.
    class Result
      extend Forwardable

      attr_reader :game, :home_score, :away_score

      def_delegators :game, :date, :home_opponent, :away_opponent, :teams

      def initialize(game:, home_score:, away_score:)
        raise ArgumentError, 'game is required' unless game

        @game       = game
        @home_score = home_score.to_i
        @away_score = away_score.to_i
      end

      def to_s
        "#{game.date} - #{away_opponent} (#{away_score}) at #{home_opponent} (#{home_score})"
      end

      def ==(other)
        game == other.game &&
          home_score == other.home_score &&
          away_score == other.away_score
      end
      alias eql? ==
    end
  end
end
