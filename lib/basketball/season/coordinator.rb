# frozen_string_literal: true

module Basketball
  module Season
    # Main iterator-based object that knows how to manage a calendar and simulate games per day.
    class Coordinator < Entity
      extend Forwardable

      class AlreadyPlayedGameError < StandardError; end
      class GameNotCurrentError < StandardError; end
      class OutOfBoundsError < StandardError; end
      class PlayedGamesError < StandardError; end
      class UnknownGameError < StandardError; end
      class UnplayedGamesError < StandardError; end

      attr_reader :calendar,
                  :current_date,
                  :arena,
                  :results,
                  :league

      def_delegators :calendar,
                     :exhibition_start_date,
                     :exhibition_end_date,
                     :regular_start_date,
                     :regular_end_date,
                     :games,
                     :exhibitions_for,
                     :regulars_for,
                     :games_for

      def initialize(calendar:, league:, current_date:, results: [])
        super()

        raise ArgumentError, 'calendar is required'     unless calendar
        raise ArgumentError, 'current_date is required' if current_date.to_s.empty?
        raise ArgumentError, 'league is required'       unless league

        @calendar     = calendar
        @current_date = current_date
        @arena        = Arena.new
        @results      = []
        @league       = league

        results.each { |result| replay!(result) }

        assert_current_date
        assert_all_past_dates_are_played
        assert_all_future_dates_arent_played
        assert_all_known_teams
      end

      def release!(player)
        tap { league.release!(player) }
      end

      def sign!(player:, team:)
        tap { league.sign!(player:, team:) }
      end

      def sim_rest!(&)
        events = []

        while not_done?
          new_events = sim!(&)

          events += new_events
        end

        events
      end

      def sim!
        raise ArgumentError, 'league is required' unless league

        return [] if done?

        events = []
        games  = games_for(date: current_date)

        games.each do |game|
          home_players = opponent_team(game.home_opponent).players
          away_players = opponent_team(game.away_opponent).players
          matchup      = Matchup.new(game:, home_players:, away_players:)
          event        = arena.play(matchup)

          play!(event)

          yield(event) if block_given?

          events << event
        end

        increment_current_date!

        events
      end

      def total_days
        (regular_end_date - exhibition_start_date).to_i
      end

      def days_left
        (regular_end_date - current_date).to_i
      end

      def total_exhibitions
        exhibitions_for.length
      end

      def exhibitions_left
        total_exhibitions - exhibition_result_events.length
      end

      def total_regulars
        regulars_for.length
      end

      def regulars_left
        total_regulars - regular_result_events.length
      end

      def current_games
        games_for(date: current_date) - results.map(&:game)
      end

      def done?
        current_date == regular_end_date && games.length == results.length
      end

      def not_done?
        !done?
      end

      def add!(game)
        assert_today_or_in_future(game)

        calendar.add!(game)

        self
      end

      def result_for(game)
        results.find do |result|
          result.game == game
        end
      end

      def regular_results
        results.select { |result| result.game.is_a?(Regular) }
      end

      def exhibition_results
        results.select { |result| result.game.is_a?(Exhibition) }
      end

      private

      attr_writer :arena

      def assert_current_date
        if current_date < exhibition_start_date
          raise OutOfBoundsError, "current date #{current_date} should be on or after #{exhibition_start_date}"
        end

        return unless current_date > regular_end_date

        raise OutOfBoundsError, "current date #{current_date} should be on or after #{exhibition_start_date}"
      end

      def opponent_team(opponent)
        league.teams.find { |t| t == opponent }
      end

      def exhibition_result_events
        results.select { |e| e.game.is_a?(Exhibition) }
      end

      def regular_result_events
        results.select { |e| e.game.is_a?(Regular) }
      end

      def increment_current_date!
        return self if current_date >= regular_end_date

        @current_date = current_date + 1

        self
      end

      def assert_today_or_in_future(game)
        return unless game.date <= current_date

        raise OutOfBoundsError, "#{game.date} is on or before the current date (#{current_date})"
      end

      def assert_all_past_dates_are_played
        games_that_should_be_played = games.select { |game| game.date < current_date }

        games_played   = results.map(&:game)
        unplayed_games = games_that_should_be_played - games_played

        return if unplayed_games.empty?

        raise UnplayedGamesError, "#{unplayed_games.length} game(s) not played before #{current_date}"
      end

      def assert_all_future_dates_arent_played
        games_that_shouldnt_be_played = results.select do |result|
          result.date > current_date
        end

        count = games_that_shouldnt_be_played.length

        return unless games_that_shouldnt_be_played.any?

        raise PlayedGamesError, "#{count} game(s) played after #{current_date}"
      end

      def play!(result)
        raise GameNotCurrentError, "#{result} is not for #{current_date}" if result.date != current_date

        replay!(result)
      end

      def replay!(result)
        raise AlreadyPlayedGameError, "#{result.game} already played!" if result_for(result.game)

        raise UnknownGameError, "game not added: #{result.game}" unless games.include?(result.game)

        results << result

        result
      end

      def assert_known_teams(game)
        raise UnknownTeamError, "unknown opponent: #{game.home_opponent}" unless league.team?(game.home_opponent)

        return if league.team?(game.away_opponent)

        raise UnknownTeamError, "unknown opponent: #{game.away_opponent}"
      end

      def assert_all_known_teams
        calendar.games.each { |game| assert_known_teams(game) }
      end
    end
  end
end
