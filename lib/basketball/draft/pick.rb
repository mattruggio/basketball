# frozen_string_literal: true

module Basketball
  module Draft
    # Room event where a player is selected.
    class Pick < Event
      attr_reader :player, :auto

      def initialize(front_office:, player:, pick:, round:, round_pick:, auto: false)
        super(front_office:, pick:, round:, round_pick:)

        raise ArgumentError, 'player required' unless player

        @player = player
        @auto   = auto
      end

      def to_s
        "#{super} #{auto ? 'auto-' : ''}picked #{player}"
      end
    end
  end
end
