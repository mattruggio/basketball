# frozen_string_literal: true

module Basketball
  module Org
    # Helper methods for objects that can be composed of divisions which are also composed of teams
    # and players.
    module HasDivisions
      include HasTeams

      def division?(division)
        divisions.include?(division)
      end

      private

      def assert_divisions_are_not_already_registered(divisions)
        divisions.each do |division|
          raise DivisionAlreadyRegisteredError, "#{division} already registered" if division?(division)

          assert_teams_are_not_already_registered(division.teams)
        end
      end
    end
  end
end
