# frozen_string_literal: true

require_relative 'roster'

module Basketball
  module Drafting
    class League
      class PlayerAlreadyRegisteredError < StandardError; end
      class TeamAlreadyAddedError < StandardError; end
      class RosterNotFoundError < StandardError; end

      attr_reader :rosters

      def initialize(teams: [])
        @rosters = []

        teams.each { |team| add_roster(team) }

        freeze
      end

      def register!(player:, team:)
        raise PlayerRequiredError, "player is required" unless player
        raise TeamRequiredError,   "team is required"   unless team

        rosters.each do |roster|
          raise PlayerAlreadyRegisteredError, "#{player} already registered to: #{roster.id}" if roster.registered?(player)
        end

        roster = rosters.find { |r| r == team }

        raise RosterNotFoundError, "Roster not found for: #{team}" unless roster

        roster.register!(player)

        self
      end

      def to_s
        ("League" + rosters.map(&:to_s)).join("\n")
      end

      private

      def add_roster(team)
        raise TeamAlreadyAddedError, "#{team} already added" if rosters.include?(team)

        rosters << Roster.new(id: team.id, name: team.name)

        self
      end
    end
  end
end
