# frozen_string_literal: true

module Basketball
  module Org
    # Describes a collection of conferences, divisions, teams, and players.
    # Holds the rules which support adding teams and players to ensure the all the
    # teams are cohesive, such as:
    #   - preventing duplicate conferences
    #   - preventing duplicate divisions
    #   - preventing duplicate teams
    #   - preventing double-signing players across teams
    class Association < Entity
      include HasDivisions

      class ConferenceAlreadyRegisteredError < StandardError; end

      attr_reader :conferences

      def initialize(conferences: [])
        super()

        @conferences = []

        conferences.each { |c| register!(c) }

        freeze
      end

      def to_s
        conferences.map(&:to_s).join("\n")
      end

      def sign!(player:, team:)
        raise ArgumentError, 'player is required' unless player
        raise ArgumentError, 'team is required' unless team
        raise UnregisteredTeamError, "#{team} not registered" unless team?(team)
        raise PlayerAlreadySignedError, "#{player} already registered" if player?(player)

        team.sign!(player)

        self
      end

      def register!(conference)
        raise ArgumentError, 'conference is required' unless conference
        raise ConferenceAlreadyRegisteredError, "#{conference} already registered" if conference?(conference)

        assert_divisions_are_not_already_registered(conference.divisions)

        conferences << conference

        self
      end

      def conference?(conference)
        conferences.include?(conference)
      end

      def divisions
        conferences.flat_map(&:divisions)
      end

      def teams
        conferences.flat_map(&:teams)
      end

      def players
        conferences.flat_map(&:players)
      end
    end
  end
end
