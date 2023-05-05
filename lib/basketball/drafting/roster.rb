# frozen_string_literal: true

module Basketball
  module Drafting
    class Roster < ValueObject
      extend Forwardable

      class WrongTeamEventError < StandardError; end

      attr_reader_value :team, :events

      def_delegators :team, :id

      def initialize(team:, events: [])
        super()

        raise ArgumentError, 'team is required' unless team

        other_teams_pick_event_ids = events.reject { |e| e.team == team }.map(&:id)

        if other_teams_pick_event_ids.any?
          raise WrongTeamEventError,
                "Event(s): #{other_teams_pick_event_ids.join(',')} has wrong team"
        end

        @team   = team
        @events = events
      end

      def players
        events.map(&:player)
      end

      def to_s
        ([team.to_s] + players.map(&:to_s)).join("\n")
      end
    end
  end
end
