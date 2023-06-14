# frozen_string_literal: true

module Basketball
  module Org
    # Base class describing a team.  A team here is bare metal and is just described by an ID
    # and a collection of Player objects.
    class Team < Entity
      attr_reader :players, :name

      def initialize(id:, name: '', players: [])
        super(id)

        @players = []
        @name    = name.to_s

        players.each { |p| sign!(p) }

        freeze
      end

      def to_s
        (["[#{super}] #{name}"] + players.map(&:to_s)).join("\n")
      end

      def signed?(player)
        players.include?(player)
      end

      def sign!(player)
        raise ArgumentError, 'player is required' unless player
        raise PlayerAlreadySignedError, "#{player} already signed by #{self}" if signed?(player)

        players << player

        self
      end
    end
  end
end
