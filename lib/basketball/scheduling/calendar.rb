# frozen_string_literal: true

module Basketball
  module Scheduling
    class Calendar < ValueObject
      class TeamAlreadyBookedError < StandardError; end
      class InvalidGameOrderError < StandardError; end
      class OutOfBoundsError < StandardError; end

      attr_reader :preseason_start_date,
                  :preseason_end_date,
                  :season_start_date,
                  :season_end_date

      attr_reader_value :year, :games

      def initialize(year:, games: [])
        super()

        raise ArgumentError, 'year is required' unless year

        @year                 = year
        @preseason_start_date = Date.new(year, 9, 30)
        @preseason_end_date   = Date.new(year, 10, 14)
        @season_start_date    = Date.new(year, 10, 18)
        @season_end_date      = Date.new(year + 1, 4, 29)
        @games                = []

        games.each { |game| add!(game) }

        freeze
      end

      def add!(game)
        assert_in_bounds(game)
        assert_free_date(game)

        @games << game

        self
      end

      def preseason_games_for(date: nil, team: nil)
        games_for(date:, team:).select { |game| game.is_a?(PreseasonGame) }
      end

      def season_games_for(date: nil, team: nil)
        games_for(date:, team:).select { |game| game.is_a?(SeasonGame) }
      end

      def games_for(date: nil, team: nil)
        games.select do |game|
          (date.nil? || game.date == date) &&
            (team.nil? || (game.home_team == team || game.away_team == team))
        end
      end

      def available_preseason_dates_for(team)
        all_preseason_dates - preseason_games_for(team:).map(&:date)
      end

      def available_season_dates_for(team)
        all_season_dates - season_games_for(team:).map(&:date)
      end

      def available_preseason_matchup_dates(team1, team2)
        available_team_dates       = available_preseason_dates_for(team1)
        available_other_team_dates = available_preseason_dates_for(team2)

        available_team_dates & available_other_team_dates
      end

      def available_season_matchup_dates(team1, team2)
        available_team_dates       = available_season_dates_for(team1)
        available_other_team_dates = available_season_dates_for(team2)

        available_team_dates & available_other_team_dates
      end

      def teams
        games.flat_map(&:teams)
      end

      private

      def all_preseason_dates
        (preseason_start_date..preseason_end_date).to_a
      end

      def all_season_dates
        (season_start_date..season_end_date).to_a
      end

      def assert_free_date(game)
        if games_for(date: game.date, team: game.home_team).any?
          raise TeamAlreadyBookedError, "#{game.home_team} already playing on #{game.date}"
        end

        return unless games_for(date: game.date, team: game.away_team).any?

        raise TeamAlreadyBookedError, "#{game.away_team} already playing on #{game.date}"
      end

      def assert_in_bounds(game)
        if game.is_a?(PreseasonGame)
          raise OutOfBoundsError, "#{game.date} is before preseason begins" if game.date < preseason_start_date
          raise OutOfBoundsError, "#{game.date} is after preseason ends"    if game.date > preseason_end_date
        elsif game.is_a?(SeasonGame)
          raise OutOfBoundsError, "#{game.date} is before season begins" if game.date < season_start_date
          raise OutOfBoundsError, "#{game.date} is after season ends"    if game.date > season_end_date
        else
          raise ArgumentError, "Dont know what this game type is: #{game.class.name}"
        end
      end
    end
  end
end
