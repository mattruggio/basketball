# frozen_string_literal: true

module Basketball
  module Scheduling
    class League
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
