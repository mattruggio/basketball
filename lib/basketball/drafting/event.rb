# frozen_string_literal: true

module Basketball
  module Drafting
    class Event < Entity
      attr_reader :pick, :round, :round_pick, :team

      def initialize(id:, team:, pick:, round:, round_pick:)
        super(id)

        raise ArgumentError, 'team required' unless team

        @team       = team
        @pick       = pick.to_i
        @round      = round.to_i
        @round_pick = round_pick.to_i
      end

      def to_s
        "##{pick} overall (R#{round}:P#{round_pick}) by #{team}"
      end
    end
  end
end
