# frozen_string_literal: true

module Basketball
  module Draft
    # A Scout knows how to process a set of players and figure out who the top prospects are.
    class Scout
      def top_for(players: [], position: nil, exclude_positions: [])
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
