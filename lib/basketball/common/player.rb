# frozen_string_literal: true

module Basketball
  module Common
    # Base class describing a player.
    # A consumer application should extend these specific to their specific sports traits.
    class Player < Entity
      attr_reader :overall, :position, :first_name, :last_name

      def initialize(id:, overall: 0, position: nil, first_name: '', last_name: '')
        super(id)

        raise ArgumentError, 'position is required' unless position

        @overall    = overall
        @position   = position
        @first_name = first_name
        @last_name  = last_name

        freeze
      end

      def full_name
        "#{first_name} #{last_name}".strip
      end

      def to_s
        "[#{super}] #{full_name} (#{position}) #{overall}".strip
      end
    end
  end
end
