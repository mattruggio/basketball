# frozen_string_literal: true

module Basketball
  module Season
    # Base class describing a team.  A team here is bare metal and is just described by an ID
    # and a collection of Player objects.
    class Team < Entity
      class PlayerNotSignedError < StandardError; end
      class MaxPlayerCountError < StandardError; end

      MAX_PLAYER_COUNT = 18

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

      def release!(player)
        raise ArgumentError, 'player is required' unless player
        raise PlayerNotSignedError, "#{player} id not signed by #{self}" unless signed?(player)

        # Returns deleted player
        players.delete(player)
      end

      def sign!(player)
        raise ArgumentError, 'player is required' unless player
        raise PlayerAlreadySignedError, "#{player} already signed by #{self}" if signed?(player)
        raise MaxPlayerCountError, "max reached: #{MAX_PLAYER_COUNT}" if players.length >= MAX_PLAYER_COUNT

        players << player

        self
      end
    end
  end
end
