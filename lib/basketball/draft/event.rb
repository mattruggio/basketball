# frozen_string_literal: true

module Basketball
  module Draft
    # Describes what all Room events have to have to be considered an "event".
    class Event < Entity
      attr_reader :round, :round_pick, :front_office

      def initialize(id:, front_office:, round:, round_pick:)
        super(id)

        raise ArgumentError, 'front_office required' unless front_office

        @front_office = front_office
        @round        = round.to_i
        @round_pick   = round_pick.to_i
      end

      def to_s
        "[#{id}] R:#{round} P:#{round_pick} - #{front_office}"
      end
    end
  end
end
