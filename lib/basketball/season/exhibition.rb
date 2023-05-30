# frozen_string_literal: true

module Basketball
  module Season
    # An exhibition game.
    class Exhibition < Game
      def to_s
        "#{super} (preseason)"
      end
    end
  end
end
