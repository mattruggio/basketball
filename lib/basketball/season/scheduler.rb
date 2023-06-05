# frozen_string_literal: true

module Basketball
  module Season
    # This is the service class responsible for actually picking out free dates and pairing up teams to
    # play each other.  This is a reasonable naive first pass at some underlying match-making algorithms
    # but could definitely use some help with the complexity/runtime/etc.
    class Scheduler
      class BadConferencesSizeError < StandardError; end
      class BadDivisionsSizeError < StandardError; end
      class BadTeamsSizeError < StandardError; end

      MIN_PRESEASON_GAMES_PER_TEAM = 3
      MAX_PRESEASON_GAMES_PER_TEAM = 6
      CONFERENCES_SIZE             = 2
      DIVISIONS_SIZE               = 3
      TEAMS_SIZE                   = 5

      private_constant :MIN_PRESEASON_GAMES_PER_TEAM,
                       :MAX_PRESEASON_GAMES_PER_TEAM,
                       :CONFERENCES_SIZE,
                       :DIVISIONS_SIZE,
                       :TEAMS_SIZE

      def schedule(league:, year: Time.now.year)
        assert_properly_sized_league(league)

        Calendar.new(**make_dates(year)).tap do |calendar|
          schedule_preseason!(calendar:, league:)
          schedule_season!(calendar:, league:)
        end
      end

      private

      def make_dates(year)
        {
          preseason_start_date: Date.new(year, 9, 30),
          preseason_end_date: Date.new(year, 10, 14),
          season_start_date: Date.new(year, 10, 18),
          season_end_date: Date.new(year + 1, 4, 29)
        }
      end

      def assert_properly_sized_league(league)
        if league.conferences.length != CONFERENCES_SIZE
          raise BadConferencesSizeError, "there has to be #{CONFERENCES_SIZE} conferences"
        end

        league.conferences.each do |conference|
          if conference.divisions.length != DIVISIONS_SIZE
            raise BadDivisionsSizeError, "#{conference.id} should have exactly #{DIVISIONS_SIZE} divisions"
          end

          conference.divisions.each do |division|
            if division.teams.length != TEAMS_SIZE
              raise BadTeamsSizeError, "#{division.id} should have exactly #{TEAMS_SIZE} teams"
            end
          end
        end
      end

      def base_matchup_count(league, team1, team2)
        # Same Conference, Same Division
        if league.division_for(team1) == league.division_for(team2)
          4
        # Same Conference, Different Division  and one of 4/10 that play 3 times
        elsif league.conference_for(team1) == league.conference_for(team2)
          3
        # Different Conference
        else
          2
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # This method derives the plan for which a schedule can be generated from.
      def matchup_plan(league)
        matchups    = {}
        game_counts = league.teams.to_h { |t| [t, 0] }
        teams       = game_counts.keys

        (0...teams.length).each do |i|
          team1 = teams[i]

          (i + 1...teams.length).each do |j|
            team2              = teams[j]
            key                = [team1, team2].sort
            count              = base_matchup_count(league, team1, team2)
            matchups[key]      = count
            game_counts[team1] += count
            game_counts[team2] += count
          end
        end

        # Each team will play 6 games against conference opponents in other divisions.
        # The fours hash will be that plan.
        find_fours(league).each do |team, opponents|
          next if game_counts[team] == 82

          opponents.each do |opponent|
            next if game_counts[team] == 82
            next if game_counts[opponent] == 82

            game_counts[team] += 1
            game_counts[opponent] += 1

            key = [team, opponent].sort

            matchups[key] += 1
          end
        end

        matchups
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # I am not liking this algorithm implementation at all but it will seemingly produce a valid
      # result about 1 out of every 1000 cycles. I have yet to spot the assignment pattern to make
      # this way more deterministic.
      def find_fours(league)
        balanced     = false
        count        = 0
        four_tracker = {}

        until balanced
          # Let's not completely thrash our CPUs in case this algorithm hits an infinite loop.
          # Instead, lets hard-fail against a hard boundary.
          raise ArgumentError, 'we spent too much CPU time and didnt resolve fours' if count > 100_000

          four_tracker = league.teams.to_h { |team| [team, []] }

          league.teams.each do |team|
            opponents = league.cross_division_opponents_for(team).shuffle

            opponents.each do |opponent|
              if four_tracker[team].length < 6 && four_tracker[opponent].length < 6
                four_tracker[opponent] << team
                four_tracker[team] << opponent
              end
            end
          end

          good = true

          # trip-wire: if one team isnt balanced then we are not balanced
          four_tracker.each { |_k, v| good = false if v.length < 6 }

          balanced = good

          count += 1
        end

        four_tracker
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def schedule_season!(calendar:, league:)
        matchups = matchup_plan(league)

        matchups.each do |(team1, team2), count|
          candidates = calendar.available_season_matchup_dates(team1, team2)
          dates      = candidates.sample(count)
          games      = balanced_games(dates, team1, team2)

          games.each { |game| calendar.add!(game) }
        end
      end

      def balanced_games(dates, team1, team2)
        dates.map.with_index(1) do |date, index|
          home_opponent, away_opponent =
            if index.even?
              [Opponent.from(team1), Opponent.from(team2)]
            else
              [Opponent.from(team2), Opponent.from(team1)]
            end

          Regular.new(date:, home_opponent:, away_opponent:)
        end
      end

      def schedule_preseason!(calendar:, league:)
        league.teams.each do |team|
          current_games = calendar.exhibitions_for(opponent: team)
          count         = current_games.length

          next if count >= MIN_PRESEASON_GAMES_PER_TEAM

          other_teams = (league.teams - [team]).shuffle

          other_teams.each do |other_team|
            break if count > MIN_PRESEASON_GAMES_PER_TEAM
            next  if calendar.exhibitions_for(opponent: other_team).length >= MAX_PRESEASON_GAMES_PER_TEAM

            candidates = calendar.available_preseason_matchup_dates(team, other_team)

            next if candidates.empty?

            date = candidates.sample
            game = random_preseason_game(date, team, other_team)

            calendar.add!(game)

            count += 1
          end
        end
      end

      def random_preseason_game(date, team1, team2)
        home_opponent, away_opponent =
          if rand(1..2) == 1
            [Opponent.from(team1), Opponent.from(team2)]
          else
            [Opponent.from(team2), Opponent.from(team1)]
          end

        Exhibition.new(date:, home_opponent:, away_opponent:)
      end
    end
  end
end
