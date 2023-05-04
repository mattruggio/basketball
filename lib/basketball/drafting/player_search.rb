# frozen_string_literal: true

module Basketball
  module Drafting
    class PlayerSearch
      attr_reader :players

      def initialize(players = [])
        @players = players
      end

      def query(position: nil, exclude_positions: [])
        filtered_players = players

        if position
          filtered_players = filtered_players.select do |player|
            player.position == position
          end
        end

        if exclude_positions.any?
          filtered_players = filtered_players.reject do |player|
            exclude_positions.include?(player.position)
          end
        end

        filtered_players.sort_by(&:overall).reverse
      end
    end
  end
end
