# frozen_string_literal: true

module Basketball
  module App
    # Knows how to flatten a League instance and rehydrate one from JSON and/or a Ruby hash.
    class LeagueRepository < DocumentRepository
      include LeagueSerializable

      private

      def from_h(hash)
        deserialize_league(hash)
      end

      def to_h(league)
        serialize_league(league)
      end
    end
  end
end
