# frozen_string_literal: true

module Basketball
  module Season
    # A Matchup is a late materialization of a game.  While a game is a skeleton for a future
    # matchup, it does not materialize until game time (rosters could change right up until game time).
    class Matchup
      class PlayersOnBothTeamsError < StandardError; end

      attr_reader :game, :home_players, :away_players

      def initialize(game:, home_players: [], away_players: [])
        raise ArgumentError, 'game is required' unless game

        @game         = game
        @home_players = home_players.uniq
        @away_players = away_players.uniq

        if home_players.intersect?(away_players)
          raise PlayersOnBothTeamsError, 'players cannot be on both home and away team'
        end

        freeze
      end
    end
  end
end
