# frozen_string_literal: true

module Basketball
  module Drafting
    class Event < Entity
      attr_reader :pick, :round, :round_pick, :front_office

      def initialize(id:, front_office:, pick:, round:, round_pick:)
        super(id)

        raise ArgumentError, 'front_office required' unless front_office

        @front_office = front_office
        @pick         = pick.to_i
        @round        = round.to_i
        @round_pick   = round_pick.to_i
      end

      def to_s
        "##{pick} overall (R#{round}:P#{round_pick}) by #{front_office}"
      end
    end
  end
end
