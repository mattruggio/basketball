# frozen_string_literal: true

module Basketball
  module Season
    # Helper methods for objects that can be composed of players.
    module HasPlayers
      def player?(player)
        players.include?(player)
      end

      private

      def assert_players_are_not_already_signed(players)
        players.each do |player|
          raise PlayerAlreadySignedError, "#{player} already registered" if player?(player)
        end
      end
    end
  end
end
