# frozen_string_literal: true

module Basketball
  module Org
    # Base class describing a player.
    # A consumer application should extend these specific to their specific sports traits.
    class Player < Entity
      attr_reader :overall, :position

      def initialize(id:, overall: 0, position: nil)
        super(id)

        raise ArgumentError, 'position is required' unless position

        @overall  = overall
        @position = position

        freeze
      end

      def to_s
        "[#{super}] (#{position}) #{overall}".strip
      end
    end
  end
end
