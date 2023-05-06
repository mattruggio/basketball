# frozen_string_literal: true

require_relative 'event'

module Basketball
  module Drafting
    class PickEvent < Event
      attr_reader :player

      def initialize(id:, front_office:, player:, pick:, round:, round_pick:)
        super(id:, front_office:, pick:, round:, round_pick:)

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
