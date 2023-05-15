# frozen_string_literal: true

module Basketball
  module Season
    class League
      class UnknownTeamError < StandardError; end

      class << self
        def generate_random; end
      end

      CONFERENCES_SIZE = 2

      attr_reader :conferences

      def initialize(conferences: [])
        @conferences = []

        conferences.each { |c| register_conference!(c) }

        if conferences.length != CONFERENCES_SIZE
          raise BadConferencesSizeError, "there has to be #{CONFERENCES_SIZE} conferences"
        end

        freeze
      end

      def to_s
        (['League'] + conferences.map(&:to_s)).join("\n")
      end

      def divisions
        conferences.flat_map(&:divisions)
      end

      def conference?(conference)
        conferences.include?(conference)
      end

      def division?(division)
        divisions.include?(division)
      end

      def team?(team)
        teams.include?(team)
      end

      def teams
        conferences.flat_map do |conference|
          conference.divisions.flat_map(&:teams)
        end
      end

      def conference_for(team)
        conferences.find { |c| c.divisions.find { |d| d.teams.include?(team) } }
      end

      def division_for(team)
        conference_for(team)&.divisions&.find { |d| d.teams.include?(team) }
      end

      # Same conference, same division
      def division_opponents_for(team)
        division = division_for(team)

        return nil unless division

        division.teams - [team]
      end

      # Same conference, different division
      def cross_division_opponents_for(team)
        conference = conference_for(team)
        division   = division_for(team)

        return nil unless conference && division

        other_divisions = conference.divisions - [division]

        other_divisions.flat_map(&:teams)
      end

      # Different conference
      def cross_conference_opponents_for(team)
        conference = conference_for(team)

        return nil unless conference

        other_conferences = conferences - [conference]

        other_conferences.flat_map { |c| c.divisions.flat_map(&:teams) }
      end

      private

      def register_conference!(conference)
        raise ArgumentError, 'conference is required' unless conference
        raise ConferenceAlreadyRegisteredError, "#{conference} already registered" if conference?(conference)

        conference.divisions.each do |division|
          raise DivisionAlreadyRegisteredError, "#{division} already registered" if division?(division)

          division.teams.each do |team|
            raise TeamAlreadyRegisteredError, "#{team} already registered" if team?(team)
          end
        end

        conferences << conference

        self
      end
    end
  end
end
