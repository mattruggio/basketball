# frozen_string_literal: true

require_relative 'calendar'

module Basketball
  module Scheduling
    class Coordinator
      class CantFulfillGamesError < StandardError; end

      MIN_PRESEASON_GAMES_PER_TEAM = 4
      MAX_PRESEASON_GAMES_PER_TEAM = 6

      private_constant :MIN_PRESEASON_GAMES_PER_TEAM,
                       :MAX_PRESEASON_GAMES_PER_TEAM

      def schedule(year:, league:)
        Calendar.new(year:).tap do |calendar|
          schedule_preseason!(calendar:, league:)
          schedule_season!(calendar:, league:)
        end
      end

      private

      def schedule_season!(calendar:, league:); end

      def schedule_preseason!(calendar:, league:)
        league.teams.each do |team|
          current_games = calendar.preseason_games_for(team:)
          count         = current_games.length

          next if count >= MIN_PRESEASON_GAMES_PER_TEAM

          other_teams = (league.teams - [team]).shuffle

          other_teams.each do |other_team|
            break if count > MIN_PRESEASON_GAMES_PER_TEAM
            next  if calendar.preseason_games_for(team: other_team).length >= MAX_PRESEASON_GAMES_PER_TEAM

            candidates = calendar.available_preseason_matchup_dates(team, other_team)

            next if candidates.empty?

            date = candidates.sample
            game = random_preseason_game(date, team, other_team)

            calendar.add!(game)

            count += 1
          end

          if count < MIN_PRESEASON_GAMES_PER_TEAM || count > MAX_PRESEASON_GAMES_PER_TEAM
            raise CantFulfillGamesError, "#{team} plays #{count} games"
          end
        end
      end

      def random_preseason_game(date, team1, team2)
        if rand(1..2) == 1
          PreseasonGame.new(date:, home_team: team1, away_team: team2)
        else
          PreseasonGame.new(date:, home_team: team2, away_team: team1)
        end
      end
    end
  end
end
