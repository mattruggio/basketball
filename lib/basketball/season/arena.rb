# frozen_string_literal: true

module Basketball
  module Season
    # A very basic implementation that will select the higher overall sum of all players while also
    # giving the home team an extra 3 overall points.
    class Arena
      # Home courts generally carry with this an inherent advantage.  So much so that even sometimes
      # leagues/teams will refer to their fans as players (i.e. NFL teams calling the fans "the 12th man")
      HOME_ADVANTAGE = 3

      private_constant :HOME_ADVANTAGE

      def play(matchup)
        home_score, away_score = home_score_and_away_score(matchup)

        Season::Result.new(
          game: matchup.game,
          home_score:,
          away_score:
        )
      end

      private

      # this could be a tie and thats fine.
      def losing_and_winning_scores
        [rand(0..5), rand(0..5)].sort
      end

      def home_score_and_away_score(matchup)
        # Take the most number of players we can but ensure same are taken from each team.
        max_players  = [matchup.home_players.length, matchup.away_players.length].min

        # Sum top player overall values
        home_overall = top_player_sum(matchup.home_players, max_players) + HOME_ADVANTAGE
        away_overall = top_player_sum(matchup.away_players, max_players)

        # Generate two random scores to use. Note: this can be a tie.
        losing_score, winning_score = losing_and_winning_scores

        # Decide who wins
        if home_overall >= away_overall
          [winning_score, losing_score]
        else
          [losing_score, winning_score]
        end
      end

      def top_player_sum(players, amount)
        players.sort_by(&:overall).reverse.take(amount).sum(&:overall)
      end
    end
  end
end
