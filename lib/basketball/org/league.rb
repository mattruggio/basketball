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
    class League < Entity
      include HasDivisions

      class ConferenceAlreadyRegisteredError < StandardError; end
      class NotSignedError < StandardError; end

      attr_reader :conferences, :free_agents

      def initialize(conferences: [], free_agents: [])
        super()

        @conferences = []
        @free_agents = []

        conferences.each { |c| register!(c) }
        free_agents.each { |p| free_agent!(p) }
      end

      def to_s
        conferences.map(&:to_s).join("\n")
      end

      def free_agent?(player)
        free_agents.include?(player)
      end

      def free_agent!(player)
        raise ArgumentError, 'player is required' unless player
        raise PlayerAlreadySignedError, "#{player} already registered" if player?(player)

        @free_agents << player

        self
      end

      def release!(player)
        raise ArgumentError, 'player is required' unless player
        raise NotSignedError, 'player is not currently signed' if free_agent?(player)

        @team.release!(player)

        self
      end

      def signed?(player)
        signed_players.include?(player)
      end

      def signed_players
        conferences.flat_map(&:players)
      end

      def sign!(player:, team:)
        raise ArgumentError, 'player is required' unless player
        raise ArgumentError, 'team is required' unless team
        raise UnregisteredTeamError, "#{team} not registered" unless team?(team)
        raise PlayerAlreadySignedError, "#{player} already registered" if signed?(player)

        # If this player was a free agent then make sure we remove them from the free agent pool.
        # It is OK if they weren't, they can still be directly signed.
        free_agents.delete(player) if free_agent?(player)

        # It is OK to pass in a detached team as long as its equivalent resides in this
        # League's object graph.
        team_for(team.id).sign!(player)

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
        conferences.flat_map(&:players) + free_agents
      end

      def conference_for(team)
        conferences.find { |c| c.divisions.find { |d| d.teams.include?(team) } }
      end

      def division_for(team)
        conference_for(team)&.divisions&.find { |d| d.teams.include?(team) }
      end

      # Same conference, different division
      def cross_division_opponents_for(team)
        conference = conference_for(team)
        division   = division_for(team)

        return nil unless conference && division

        other_divisions = conference.divisions - [division]

        other_divisions.flat_map(&:teams)
      end

      def team_for(id)
        teams.find { |team| team.id == id }
      end
    end
  end
end
