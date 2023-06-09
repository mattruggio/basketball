# frozen_string_literal: true

module Basketball
  module Common
    # Describes a player position.
    class Position < ValueObject
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

      value_reader :code

      def_delegators :code, :to_s

      def initialize(code)
        super()

        @code = code.to_s.upcase

        raise InvalidPositionError, "Unknown position code: #{@code}" unless ALL_VALUES.include?(@code)

        freeze
      end
    end
  end
end
