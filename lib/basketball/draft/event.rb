# frozen_string_literal: true

module Basketball
  module Draft
    # Describes what all Room events have to have to be considered an "event".
    class Event
      attr_reader :pick, :round, :round_pick, :front_office

      def initialize(front_office:, pick:, round:, round_pick:)
        super()

        raise ArgumentError, 'front_office required' unless front_office

        @front_office = front_office
        @pick         = pick.to_i
        @round        = round.to_i
        @round_pick   = round_pick.to_i
      end

      def to_s
        "[##{pick} R:#{round} P:#{round_pick}] #{front_office}"
      end

      def ==(other)
        front_office == other.front_office &&
          pick == other.pick &&
          round == other.round &&
          round_pick == other.round_pick
      end
      alias eql? ==
    end
  end
end
