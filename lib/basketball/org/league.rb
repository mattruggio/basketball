# frozen_string_literal: true

module Basketball
  module Org
    # Describes a collection of teams and players.  Holds the rules which support
    # adding teams and players to ensure the all the teams are cohesive, such as:
    #   - preventing duplicate teams
    #   - preventing double-signing players across teams
    class League < Entity
      class TeamAlreadyRegisteredError < StandardError; end
      class UnregisteredTeamError < StandardError; end

      attr_reader :teams

      def initialize(teams: [])
        super()

        @teams = []

        teams.each { |team| register!(team) }
      end

      def to_s
        teams.map(&:to_s).join("\n")
      end

      def sign!(player:, team:)
        raise ArgumentError, 'player is required' unless player
        raise ArgumentError, 'team is required' unless team
        raise UnregisteredTeamError, "#{team} is not registered" unless registered?(team)
        raise PlayerAlreadySignedError, "#{player} is already signed" if signed?(player)

        team.sign!(player)

        self
      end

      def signed?(player)
        players.include?(player)
      end

      def players
        teams.flat_map(&:players)
      end

      def not_registered?(team)
        !registered?(team)
      end

      def registered?(team)
        teams.include?(team)
      end

      def register!(team)
        raise ArgumentError, 'team is required' unless team
        raise TeamAlreadyRegisteredError, "#{team} already registered" if registered?(team)

        team.players.each do |player|
          raise PlayerAlreadySignedError, "#{player} already signed" if signed?(player)
        end

        teams << team

        self
      end
    end
  end
end
