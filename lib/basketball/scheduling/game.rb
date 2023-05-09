# frozen_string_literal: true

module Basketball
  module Scheduling
    class Game < ValueObject
      attr_reader_value :date, :home_team, :away_team

      def initialize(date:, home_team:, away_team:)
        super()

        raise ArgumentError, 'date is required'             unless date
        raise ArgumentError, 'home_team is required'        unless home_team
        raise ArgumentError, 'away_team is required'        unless away_team
        raise ArgumentError, 'teams cannot play themselves' if home_team == away_team

        @date      = date
        @home_team = home_team
        @away_team = away_team

        freeze
      end

      def teams
        [home_team, away_team]
      end
    end
  end
end
