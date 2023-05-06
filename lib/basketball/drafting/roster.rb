# frozen_string_literal: true

module Basketball
  module Drafting
    class Roster < Entity
      class PlayerAlreadyRegisteredError < StandardError; end
      class PlayerRequiredError < StandardError; end

      attr_reader :name, :players

      def initialize(id:, name: '', players: [])
        super(id)

        @name    = name.to_s
        @players = players.each { |p| register!(p) }

        freeze
      end

      def registered?(player)
        players.include?(player)
      end

      def sign!(player)
        raise PlayerRequiredError, 'player is required' unless player
        raise PlayerAlreadyRegisteredError, "#{player} already registered for #{id}" if registered?(player)

        players << player

        self
      end

      def to_s
        (["[#{super}] #{name} Roster"] + players.map(&:to_s)).join("\n")
      end
    end
  end
end
