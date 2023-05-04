# frozen_string_literal: true

module Basketball
  module Drafting
    class Position
      extend Forwardable

      class << self
        def random
          new(ALL_VALUES.to_a.sample)
        end
      end

      class InvalidPositionError < StandardError; end

      BACK_COURT_VALUES  = %w[PG SG SF].to_set.freeze
      FRONT_COURT_VALUES = %w[PF C].to_set.freeze
      ALL_VALUES         = (BACK_COURT_VALUES.to_a + FRONT_COURT_VALUES.to_a).to_set.freeze

      attr_reader :value

      def_delegators :value, :to_s

      def initialize(value)
        @value = value.to_s.upcase

        raise InvalidPositionError, "Unknown position value: #{@value}" unless ALL_VALUES.include?(@value)

        freeze
      end

      def ==(other)
        value == other.value
      end
      alias eql? ==

      def hash
        value.hash
      end
    end
  end
end
