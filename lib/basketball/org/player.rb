# frozen_string_literal: true

module Basketball
  module Org
    # Base class describing a player.
    # A consumer application should extend these specific to their specific sports traits.
    class Player < Entity
      attr_reader :overall

      def initialize(id:, overall: 0)
        super(id)

        @overall = overall
      end

      def to_s
        "#{super} (#{overall})"
      end
    end
  end
end
