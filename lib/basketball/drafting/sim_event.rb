# frozen_string_literal: true

module Basketball
  module Drafting
    class SimEvent < Event
      attr_reader_value :player

      def initialize(front_office:, player:, pick:, round:, round_pick:)
        super(front_office:, pick:, round:, round_pick:)

        raise ArgumentError, 'player required' unless player

        @player = player

        freeze
      end

      def to_s
        "#{player} auto-picked #{super}"
      end
    end
  end
end
