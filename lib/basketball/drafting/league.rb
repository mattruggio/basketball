# frozen_string_literal: true

require_relative 'roster'

module Basketball
  module Drafting
    class League
      class PlayerAlreadyRegisteredError < StandardError; end
      class RosterNotFoundError < StandardError; end
      class RosterAlreadyAddedError < StandardError; end

      attr_reader :free_agents, :rosters

      def initialize(free_agents: [], front_offices: [])
        @rosters     = []
        @free_agents = []

        front_offices.each { |front_office| add_roster(front_office) }
        free_agents.each   { |p| register!(player: p) }

        freeze
      end

      def roster(front_office)
        rosters.find { |r| r == front_office }
      end

      def register!(player:, front_office: nil)
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

        if front_office
          roster = roster(front_office)

          raise RosterNotFoundError, "Roster not found for: #{front_office}" unless roster

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

      def add_roster(front_office)
        raise RosterAlreadyAddedError, "#{front_office} already added" if rosters.include?(front_office)

        rosters << Roster.new(id: front_office.id, name: front_office.name)

        self
      end
    end
  end
end
