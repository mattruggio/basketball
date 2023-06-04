# frozen_string_literal: true

module Basketball
  module Org
    # Helper methods for objects that can be composed of teams which are also made up of players.
    module HasTeams
      include HasPlayers

      def team?(team)
        teams.include?(team)
      end

      private

      def assert_teams_are_not_already_registered(teams)
        teams.each do |team|
          raise TeamAlreadyRegisteredError, "#{team} already registered" if team?(team)

          assert_players_are_not_already_signed(team.players)
        end
      end
    end
  end
end
