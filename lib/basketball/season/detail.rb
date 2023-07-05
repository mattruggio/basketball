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

      # rubocop:disable Metrics/CyclomaticComplexity
      def initialize(date:, home:, opponent:, opponent_score:, score:, opponent_type:)
        super()

        raise ArgumentError,  'date is required'           unless date
        raise ArgumentError,  'opponent is required'       unless opponent
        raise ArgumentError,  'score is required'          unless score
        raise ArgumentError,  'opponent_score is required' unless opponent_score
        raise ArgumentError,  'home is required'           if home.nil?
        raise CannotTieError, 'scores cannot be equal'     if score == opponent_score
        raise ArgumentError,  'opponent_type is required'  unless opponent_type

        @date           = date
        @opponent       = opponent
        @score          = score
        @opponent_score = opponent_score
        @home           = home
        @opponent_type  = OpponentType.parse(opponent_type)

        freeze
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def divisional?
        opponent_type == INTRA_DIVISIONAL
      end

      def intra_conference?
        opponent_type == INTRA_CONFERENCE
      end

      def inter_conterence?
        opponent_type == INTER_CONFERENCE
      end

      def win?
        score > opponent_score
      end

      def loss?
        score < opponent_score
      end

      def to_s
        win_display = win? ? 'win' : 'loss'
        vs_display  = home? ? 'vs' : 'at'

        "[#{date}] #{opponent_type} #{win_display} #{vs_display} #{opponent} (#{score}-#{opponent_score})"
      end
    end
  end
end
