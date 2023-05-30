# frozen_string_literal: true

module Basketball
  module Season
    # A very, very, very basic starting point for a "semi-randomized" game simulator.
    class Arena
      RANDOM             = :random
      TOP_ONE            = :top_one
      TOP_TWO            = :top_two
      TOP_THREE          = :top_three
      TOP_SIX            = :top_six
      MAX_HOME_ADVANTAGE = 5

      STRATEGY_FREQUENCIES = {
        RANDOM => 10,
        TOP_ONE => 5,
        TOP_TWO => 10,
        TOP_THREE => 20,
        TOP_SIX => 30
      }.freeze

      private_constant :STRATEGY_FREQUENCIES,
                       :RANDOM,
                       :TOP_ONE,
                       :TOP_TWO,
                       :TOP_SIX,
                       :MAX_HOME_ADVANTAGE

      def initialize
        @lotto = STRATEGY_FREQUENCIES.inject([]) do |memo, (name, frequency)|
          memo + ([name] * frequency)
        end.shuffle

        freeze
      end

      def play(matchup)
        scores        = generate_scores
        winning_score = scores.max
        losing_score  = scores.min
        strategy      = pick_strategy

        if home_wins?(matchup, strategy)
          Result.new(
            game: matchup.game,
            home_score: winning_score,
            away_score: losing_score
          )
        else
          Result.new(
            game: matchup.game,
            home_score: losing_score,
            away_score: winning_score
          )
        end
      end

      private

      attr_reader :lotto

      def pick_strategy
        lotto.sample
      end

      def home_wins?(game, strategy)
        send("#{strategy}_strategy", game)
      end

      def top_player_sum(players, amount)
        players.sort_by(&:overall).reverse.take(amount).sum(&:overall)
      end

      def generate_scores
        scores = [
          rand(70..130),
          rand(70..130)
        ]

        # No ties
        scores[0] += 1 if scores[0] == scores[1]

        scores
      end

      def random_strategy(_game)
        # 60% chance home wins
        (([0] * 6) + ([1] * 4)).sample.zero?
      end

      def random_home_advantage
        rand(0..MAX_HOME_ADVANTAGE)
      end

      def top_one_strategy(matchup)
        top_player_sum(matchup.home_players, 1) + random_home_advantage >= top_player_sum(matchup.away_players, 1)
      end

      def top_two_strategy(matchup)
        top_player_sum(matchup.home_players, 2) + random_home_advantage >= top_player_sum(matchup.away_players, 2)
      end

      def top_three_strategy(matchup)
        top_player_sum(matchup.home_players, 3) + random_home_advantage >= top_player_sum(matchup.away_players, 3)
      end

      def top_six_strategy(matchup)
        top_player_sum(matchup.home_players, 6) + random_home_advantage >= top_player_sum(matchup.away_players, 6)
      end
    end
  end
end
