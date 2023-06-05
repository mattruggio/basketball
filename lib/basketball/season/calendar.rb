# frozen_string_literal: true

module Basketball
  module Season
    # Sets boundaries for preseason and regular season play.  Add games as long as they are
    # within the correct dated boundaries
    class Calendar
      class OutOfBoundsError < StandardError; end
      class TeamAlreadyBookedError < StandardError; end

      attr_reader :preseason_start_date,
                  :preseason_end_date,
                  :season_start_date,
                  :season_end_date,
                  :games

      def initialize(
        preseason_start_date:,
        preseason_end_date:,
        season_start_date:,
        season_end_date:,
        games: []
      )
        raise ArgumentError, 'preseason_start_date is required' if preseason_start_date.to_s.empty?
        raise ArgumentError, 'preseason_end_date is required'   if preseason_end_date.to_s.empty?
        raise ArgumentError, 'season_start_date is required'    if season_start_date.to_s.empty?
        raise ArgumentError, 'season_end_date is required'      if season_end_date.to_s.empty?

        @preseason_start_date = preseason_start_date
        @preseason_end_date   = preseason_end_date
        @season_start_date    = season_start_date
        @season_end_date      = season_end_date
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

      def exhibitions_for(date: nil, opponent: nil)
        games_for(date:, opponent:).select { |game| game.is_a?(Exhibition) }
      end

      def regulars_for(date: nil, opponent: nil)
        games_for(date:, opponent:).select { |game| game.is_a?(Regular) }
      end

      def games_for(date: nil, opponent: nil)
        games.select do |game|
          (date.nil? || game.date == date) && (opponent.nil? || game.for?(opponent))
        end
      end

      def available_preseason_dates_for(opponent)
        all_preseason_dates - exhibitions_for(opponent:).map(&:date)
      end

      def available_season_dates_for(opponent)
        all_season_dates - regulars_for(opponent:).map(&:date)
      end

      def available_preseason_matchup_dates(opponent1, opponent2)
        available_opponent_dates       = available_preseason_dates_for(opponent1)
        available_other_opponent_dates = available_preseason_dates_for(opponent2)

        available_opponent_dates & available_other_opponent_dates
      end

      def available_season_matchup_dates(opponent1, opponent2)
        available_opponent_dates       = available_season_dates_for(opponent1)
        available_other_opponent_dates = available_season_dates_for(opponent2)

        available_opponent_dates & available_other_opponent_dates
      end

      private

      def all_preseason_dates
        (preseason_start_date..preseason_end_date).to_a
      end

      def all_season_dates
        (season_start_date..season_end_date).to_a
      end

      def assert_free_date(game)
        if games_for(date: game.date, opponent: game.home_opponent).any?
          raise TeamAlreadyBookedError, "#{game.home_opponent} already playing on #{game.date}"
        end

        return unless games_for(date: game.date, opponent: game.away_opponent).any?

        raise TeamAlreadyBookedError, "#{game.away_opponent} already playing on #{game.date}"
      end

      def assert_in_bounds(game)
        date = game.date

        if game.is_a?(Exhibition)
          raise OutOfBoundsError, "#{date} is before preseason begins" if date < preseason_start_date
          raise OutOfBoundsError, "#{date} is after preseason ends"    if date > preseason_end_date
        elsif game.is_a?(Regular)
          raise OutOfBoundsError, "#{date} is before season begins" if date < season_start_date
          raise OutOfBoundsError, "#{date} is after season ends"    if date > season_end_date
        else
          raise ArgumentError, "Dont know what this game type is: #{game.class.name}"
        end
      end
    end
  end
end
