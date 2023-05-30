# frozen_string_literal: true

module Basketball
  module Draft
    # An assessment is given to a front office when it needs the front office to make a pick.
    # This is essentially just a data-transfer object to get information to a front office to make a pick.
    class Assessment
      attr_reader :drafted_players,
                  :pick,
                  :round_pick,
                  :round,
                  :undrafted_players

      def initialize(
        drafted_players:,
        pick:,
        round_pick:,
        round:,
        undrafted_players:
      )
        @drafted_players   = drafted_players
        @pick              = pick
        @round             = round
        @round_pick        = round_pick
        @undrafted_players = undrafted_players

        freeze
      end
    end
  end
end
