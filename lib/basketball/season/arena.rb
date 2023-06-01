# frozen_string_literal: true

module Basketball
  module Season
    # A very, very, very basic starting point for a "semi-randomized" game simulator.
    class Arena
      RANDOM    = :random
      TOP_ONE   = :top_one
      TOP_TWO   = :top_two
      TOP_THREE = :top_three
      TOP_SIX   = :top_six
      DEFAULT_MAX_HOME_ADVANTAGE = 5

      DEFAULT_STRATEGY_FREQUENCIES = {
        RANDOM => 10,
        TOP_ONE => 5,
        TOP_TWO => 10,
        TOP_THREE => 20,
        TOP_SIX => 30
      }.freeze

      attr_reader :lotto, :max_home_advantage

      def initialize(
        strategy_frquencies: DEFAULT_STRATEGY_FREQUENCIES,
        max_home_advantage: DEFAULT_MAX_HOME_ADVANTAGE
      )
        @max_home_advantage = max_home_advantage
        @lotto              = make_lotto(strategy_frquencies)

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

      def make_lotto(strategy_frquencies)
        strategy_frquencies.inject([]) do |memo, (name, frequency)|
          memo + ([name] * frequency)
        end.shuffle
      end

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
          rand(70..120),
          rand(70..120)
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
        rand(0..max_home_advantage)
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
