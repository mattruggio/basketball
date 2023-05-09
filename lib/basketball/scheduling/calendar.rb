# frozen_string_literal: true

module Basketball
  module Scheduling
    class Calendar
      class TeamAlreadyBookedError < StandardError; end
      class InvalidGameOrderError < StandardError; end

      attr_reader :games

      def initialize(games: [])
        @games = []

        games.each { |game| add!(game) }

        freeze
      end

      def add!(game)
        assert_free_date(game)
        assert_proper_order(game)

        @games << game

        self
      end

      def games_for(date: nil, team: nil)
        games.select do |game|
          (date.nil? || game.date == date) &&
            (team.nil? || (game.home_team == team || game.away_team == team))
        end
      end

      private

      def first_season_game_date
        games.sort_by(&:date).select { |g| g.is_a?(SeasonGame) }.first&.date
      end

      def last_preseason_game_date
        games.sort_by(&:date).select { |g| g.is_a?(PreseasonGame) }.last&.date
      end

      def assert_free_date(game)
        if games_for(date: game.date, team: game.home_team).any?
          raise TeamAlreadyBookedError, "#{game.home_team} already playing on #{game.date}"
        end

        return unless games_for(date: game.date, team: game.away_team).any?

        raise TeamAlreadyBookedError, "#{game.away_team} already playing on #{game.date}"
      end

      def assert_proper_order(game)
        if first_season_game_date && game.is_a?(PreseasonGame) && game.date >= first_season_game_date
          raise InvalidGameOrderError, "#{game.date} cant be on or after #{first_season_game_date}"
        end

        return unless last_preseason_game_date && game.is_a?(SeasonGame) && game.date <= last_preseason_game_date

        raise InvalidGameOrderError, "#{game.date} cant be on or before #{last_preseason_game_date}"
      end
    end
  end
end
