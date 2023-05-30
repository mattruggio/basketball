# frozen_string_literal: true

module Basketball
  module Draft
    # Room event where a player is selected.
    class Pick < Event
      value_reader :player, :auto

      def initialize(front_office:, player:, pick:, round:, round_pick:, auto: false)
        super(front_office:, pick:, round:, round_pick:)

        raise ArgumentError, 'player required' unless player

        @player = player
        @auto   = auto

        freeze
      end

      def to_s
        "#{super} #{auto ? 'auto-' : ''}picked #{player}"
      end

      def ==(other)
        super &&
          player == other.player &&
          auto == other.auto
      end
      alias eql? ==
    end
  end
end
