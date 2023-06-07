# frozen_string_literal: true

module Basketball
  module Season
    # Describes a result from the perspective of a team.
    class Detail < ValueObject
      value_reader :date,
                   :home,
                   :opponent_score,
                   :opponent,
                   :score

      alias home? home

      def initialize(date:, home:, opponent:, opponent_score:, score:)
        super()

        raise ArgumentError,  'date is required'           unless date
        raise ArgumentError,  'opponent is required'       unless opponent
        raise ArgumentError,  'score is required'          unless score
        raise ArgumentError,  'opponent_score is required' unless opponent_score
        raise ArgumentError,  'home is required'           if home.nil?
        raise CannotTieError, 'scores cannot be equal'     if score == opponent_score

        @date           = date
        @opponent       = opponent
        @score          = score
        @opponent_score = opponent_score
        @home           = home

        freeze
      end

      def win?
        score > opponent_score
      end

      def loss?
        score < opponent_score
      end

      def to_s
        "[#{date}] #{win? ? 'Win' : 'Loss'} #{home? ? 'vs' : 'at'} #{opponent} (#{score}-#{opponent_score})"
      end
    end
  end
end
