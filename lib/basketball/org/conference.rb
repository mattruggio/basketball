# frozen_string_literal: true

module Basketball
  module Org
    # A collection of divisions, teams, and players.
    class Conference < Entity
      include HasDivisions

      attr_reader :divisions

      def initialize(id:, divisions: [])
        super(id)

        @divisions = []

        divisions.each { |d| register_division!(d) }

        freeze
      end

      def to_s
        ([super] + divisions.map(&:to_s)).join("\n")
      end

      def teams
        divisions.flat_map(&:teams)
      end

      def players
        divisions.flat_map(&:players)
      end

      private

      def register_division!(division)
        raise ArgumentError, 'division is required' unless division
        raise DivisionAlreadyRegisteredError, "#{division} already registered" if division?(division)

        assert_teams_are_not_already_registered(division.teams)

        divisions << division

        self
      end
    end
  end
end
