# frozen_string_literal: true

module Basketball
  module Season
    class PreseasonGame < Game
      def to_s
        "#{super} (preseason)"
      end
    end
  end
end
