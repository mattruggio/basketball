# frozen_string_literal: true

module Basketball
  module Drafting
    class PickEvent < Event
      attr_reader :player

      def initialize(id:, team:, player:, pick:, round:, round_pick:)
        super(id:, team:, pick:, round:, round_pick:)

        raise ArgumentError, 'player required' unless player

        @player = player

        freeze
      end

      def to_s
        "#{player} picked #{super}"
      end
    end
  end
end
