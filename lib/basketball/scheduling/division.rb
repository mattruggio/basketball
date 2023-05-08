# frozen_string_literal: true

module Basketball
  module Scheduling
    class Division < Entity
      TEAMS_SIZE = 5

      attr_reader :name, :teams

      def initialize(id:, name: '', teams: [])
        super(id)

        @name  = name.to_s
        @teams = []

        teams.each { |t| register_team!(t) }

        raise BadTeamsSizeError, "#{id} should have exactly #{TEAMS_SIZE} teams" if teams.length != TEAMS_SIZE

        freeze
      end

      def to_s
        (["[#{super}] #{name}"] + teams.map(&:to_s)).join("\n")
      end

      def team?(team)
        teams.include?(team)
      end

      private

      def register_team!(team)
        raise ArgumentError, 'team is required' unless team
        raise TeamAlreadyRegisteredError, "#{team} already registered" if team?(team)

        teams << team

        self
      end
    end
  end
end
