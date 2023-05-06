# frozen_string_literal: true

require_relative 'roster'

module Basketball
  module Drafting
    class League
      class PlayerAlreadyRegisteredError < StandardError; end
      class RosterNotFoundError < StandardError; end

      attr_reader :free_agents, :rosters

      def initialize(free_agents: [], teams: [])
        @rosters     = []
        @free_agents = []

        teams.each       { |team| add_roster(team) }
        free_agents.each { |p| register!(player: p) }

        freeze
      end

      def roster(team)
        rosters.find { |r| r == team }
      end

      def register!(player:, team: nil)
        raise PlayerRequiredError, 'player is required' unless player

        rosters.each do |roster|
          if roster.registered?(player)
            raise PlayerAlreadyRegisteredError,
                  "#{player} already registered to: #{roster.id}"
          end
        end

        if free_agents.include?(player)
          raise PlayerAlreadyRegisteredError,
                "#{player} already registered as a free agent"
        end

        if team
          roster = roster(team)

          raise RosterNotFoundError, "Roster not found for: #{team}" unless roster

          roster.sign!(player)
        else
          free_agents << player
        end

        self
      end

      def to_s
        (['League'] + rosters.map(&:to_s)).join("\n")
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
