# frozen_string_literal: true

module Basketball
  module Season
    # Represents a team without a roster.  Equal to a team by identity.
    # A team's roster will not be known until the last minute (when it is game time).
    class Opponent < Entity
      class << self
        def from(team)
          new(id: team.id)
        end
      end

      def initialize(id:)
        super(id)

        freeze
      end
    end
  end
end
