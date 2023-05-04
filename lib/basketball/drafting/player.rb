# frozen_string_literal: true

require_relative 'entity'

module Basketball
  module Drafting
    class Player < Entity
      STAR_THRESHOLD         = 75
      OVERALL_STAR_INDICATOR = '⭐'

      private_constant :STAR_THRESHOLD, :OVERALL_STAR_INDICATOR

      attr_reader :first_name, :last_name, :position, :overall

      def initialize(id:, position:, first_name: '', last_name: '', overall: 0)
        super(id)

        raise ArgumentError, 'position is required' unless position

        @first_name = first_name.to_s
        @last_name  = last_name.to_s
        @position   = position
        @overall    = overall.to_i

        freeze
      end

      def full_name
        "#{first_name.strip} #{last_name.strip}".strip
      end

      def to_s
        "[#{super}] #{full_name} (#{position}) #{overall} #{star_indicators.join(', ')}".strip
      end

      private

      def star_indicators
        [].tap do |indicators|
          indicators << OVERALL_STAR_INDICATOR if overall >= STAR_THRESHOLD
        end
      end
    end
  end
end
