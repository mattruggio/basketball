# frozen_string_literal: true

module Basketball
  module Scheduling
    class PreseasonGame < Game
      def to_s
        "#{super} (preseason)"
      end
    end
  end
end
